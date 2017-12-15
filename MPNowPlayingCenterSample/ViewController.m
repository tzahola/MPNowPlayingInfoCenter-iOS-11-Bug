//
//  ViewController.m
//  MPNowPlayingCenterSample
//
//  Created by Tamas Zahola on 2017. 12. 15..
//  Copyright © 2017. Skyscanner. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton* playPauseButton;

@end

@implementation ViewController {
    AVAudioPlayer* _player;
    BOOL _isPlaying;
}

- (IBAction)playPauseButtonPressed:(id)sender {
    [self togglePlayPause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL* fileURL = [NSBundle.mainBundle URLForResource:@"alphabet" withExtension:@"m4a"];
    NSError* error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    NSAssert(_player != nil, @"%@", error);
    
    AVAudioSession* audioSession = AVAudioSession.sharedInstance;
    BOOL didSet = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    NSAssert(didSet, @"%@", error);
    
    didSet = [audioSession setMode:AVAudioSessionModeDefault error:&error];
    NSAssert(didSet, @"%@", error);
    
    didSet = [audioSession setActive:YES error:&error];
    NSAssert(didSet, @"%@", error);
    
    MPRemoteCommandCenter* commandCenter = MPRemoteCommandCenter.sharedCommandCenter;
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self togglePlayPause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        _player.currentTime = 0;
        [self refresh];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        _player.currentTime = 0;
        [self refresh];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        _player.currentTime = ((MPChangePlaybackPositionCommandEvent*)event).positionTime;
        [self refresh];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [self refresh];
}

- (void)togglePlayPause {
    if (_isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)play {
    NSAssert(!_isPlaying, @"Already playing");
    _isPlaying = YES;
    [_player play];
    [self refresh];
}

- (void)pause {
    NSAssert(_isPlaying, @"Not playing");
    _isPlaying = NO;
    [_player pause];
    [self refresh];
}

- (void)refresh {
    [self.playPauseButton setTitle:_isPlaying ? @"Pause" : @"Play" forState:UIControlStateNormal];
    
    NSDictionary* info = @{
        MPMediaItemPropertyAlbumTitle: @"Alex",
        MPMediaItemPropertyTitle: @"The Alphabet",
        MPNowPlayingInfoPropertyMediaType: @(MPMediaTypeMusic),
        MPMediaItemPropertyPlaybackDuration: @(_player.duration),
        MPNowPlayingInfoPropertyPlaybackRate: @(_isPlaying ? _player.rate : 0),
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @(_player.currentTime)
    };
    NSLog(@"%@", info);
    MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = info;
}

@end
