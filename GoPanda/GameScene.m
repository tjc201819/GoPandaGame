//
//  GameScene.m
//  GoPanda
//
//  Created by Ekaterina Krasnova on 07.06.16.
//  Copyright (c) 2016 Ekaterina Krasnova. All rights reserved.
//

#import "GameScene.h"
#import "MenuScenesController.h"
#import "KKGameData.h"
#import "GameViewController.h"

@interface GameScene ()

@property (strong, nonatomic) SKSpriteNode *background;

@end

typedef enum {
    kEndReasonWin,
    kEndReasonLose
} EndReason;

@implementation GameScene

BOOL isHurtAnimationRunning;
BOOL isPandaFall;
BOOL isPandaJump;
BOOL isExit;
float lastCameraPosition;
int level;
SKNode *exitSign;
SKSpriteNode *endGame;
SKCameraNode *camera;
NSMutableArray<SKSpriteNode *> *coins;
NSMutableArray<SKSpriteNode *> *pickUpHearts;
NSMutableArray<SKSpriteNode *> *pickUpClocks;
NSMutableArray<SKSpriteNode *> *pickUpStars;

NSMutableArray<SKSpriteNode *> *hearts;

NSMutableArray<SKSpriteNode *> *bluesnails;
NSMutableArray<SKSpriteNode *> *redsnails;
NSMutableArray<SKSpriteNode *> *mushrooms;
NSMutableArray<SKSpriteNode *> *flowers;
NSMutableArray<SKSpriteNode *> *flowersSpit;
NSMutableArray<SKSpriteNode *> *borders;
NSMutableArray<SKSpriteNode *> *littlePandas;
NSMutableArray<SKSpriteNode *> *littlePandasMoving;
NSMutableArray<NSNumber *> *littlePandasMoveStartPosition;
SKSpriteNode *leftMoveButton;
SKSpriteNode *rightMoveButton;
SKSpriteNode *jumpButton;

AVAudioPlayer *backgroundGameMusic;
AVAudioPlayer *sound;
NSMutableArray *soundsArray;

-(void)didMoveToView:(SKView *)view {
    
    soundsArray = [NSMutableArray new];
    
    isFlowerAttackAnimation = NO;
    
    isLeftMoveButton = NO;
    isRightMoveButton = NO;
    isJumpButton = NO;
    
    isExit = NO;
    
    isPandaFall = NO;
    isDieAnimation = NO;
    isPandaJump = NO;
    isHurtAnimationRunning = NO;
    
    level = [KKGameData sharedGameData].currentLevel;
    
    //Set background music
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mainTheme" ofType:@"mp3"];
    backgroundGameMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    backgroundGameMusic.delegate = self;
    backgroundGameMusic.numberOfLoops = -1;
    backgroundGameMusic.volume = [KKGameData sharedGameData].musicVolume;
    [backgroundGameMusic play];

    
    // Set boundaries
    /*SKNode *background = [self childNodeWithName:@"background"];
    SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:background.frame];
    self.physicsBody = borderBody;
    self.physicsBody.friction = 1.0f; */
    
    // Set boundaries and background   //NEW
    exitSign = [self childNodeWithName:@"exitSign"];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, exitSign.position.x + 200, 680)];
    
    int k = exitSign.position.x / 1024;
    for (int i = 0; i <= k; i++) {
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        _background.xScale = 1.03;
        _background.yScale = 1.03;
        _background.zPosition = -99;
        _background.anchorPoint = CGPointZero;
        _background.position = CGPointMake(i * _background.size.width, 0);
        [self addChild:_background];
    }
    
    
    
    //Add Panda Character
    /*SKSpriteNode *panda = [SKSpriteNode spriteNodeWithImageNamed:@"Idle_001"];
    panda.xScale = 0.5;
    panda.yScale = 0.5;
    panda.anchorPoint = CGPointZero;
    panda.position = CGPointMake(0, 0);
    [self addChild:panda]; */
    
    //Create Panda run animation
    NSMutableArray<SKTexture *> *textures = [NSMutableArray new];
    for (int i = 0; i <= 5; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Run_00%i",i]]];
    }
//    [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Idle_000"]]];
    self.runAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Create Panda jump animation
    textures = [NSMutableArray new];
    for (int i = 0; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Jump2_00%i",i]]];
    }
//    self.jumpAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    self.jumpAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
    
    //Create Panda idle animation
    textures = [NSMutableArray new];
    for (int i = 0; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Idle_00%i",i]]];
    }
    self.idleAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    // Create Panda hurt animation
    textures = [NSMutableArray new];
    for (int i = 0; i <= 1; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Hurt_00%i", i]]];
    }
    self.hurtAnimation = [SKAction sequence:@[[SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.1] count:1], [SKAction repeatAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.6 duration:0.15], [SKAction fadeAlphaTo:1.0 duration:0.15]]] count:4]]];
    
    // Create Panda die animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Die_00%i", i]]];
    }
    self.dieAnimation = [SKAction sequence:@[[SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.2] count:1]]];
    //[SKAction waitForDuration:3.0]
    
    //Create Coin animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 6; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Coin0%i", i]]];
    }
    self.coinAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Create blue snails idle animation
    textures = [NSMutableArray new];
    for (int i = 2; i <= 5; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"bluesnail_0%i", i]]];
    }
    self.blueSnailIdleAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Create blue Snail Hurt Animation
    textures = [NSMutableArray new];
    for (int i = 6; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"bluesnail_0%i",i]]];
    }
    
    self.blueSnailHurtAnimation = [SKAction sequence:@[
                        [SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.15] count:1],
                        [SKAction fadeOutWithDuration:1.5]]];

    //Create red snails idle animation
    textures = [NSMutableArray new];
    for (int i = 2; i <= 5; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"redsnail_0%i", i]]];
    }
    self.redSnailIdleAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Create red Snail Hurt Animation
    textures = [NSMutableArray new];
    for (int i = 6; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"redsnail_0%i",i]]];
    }
    self.redSnailHurtAnimation = [SKAction sequence:@[
                        [SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.15] count:1],
                        [SKAction fadeOutWithDuration:1.5]]];
    
    //Create mushroom idle animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 6; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"mushroom_0%i", i]]];
    }
    self.mushroomIdleAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Create mushroom hurt animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 8; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"mushroomhurt_0%i", i]]];
    }
    self.mushroomHurtAnimation = [SKAction sequence:@[
                        [SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.1] count:1],
                        [SKAction fadeOutWithDuration:1.5]]];
    
    //Create flower idle animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 6; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"floweridle_0%i", i]]];
    }
    self.flowerIdleAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Create flower hurt animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 7; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"flowerhurt_0%i", i]]];
    }
    self.flowerHurtAnimation = [SKAction sequence:@[
                                            [SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.1] count:1],
                                            [SKAction fadeOutWithDuration:1.5]]];
    //Creat little panda eat animation
    textures = [NSMutableArray new];
    for (int i = 2; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"littlePandaEat_0%i", i]]];
    }
    self.littlePandaEat = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.2]];
    
    //Creat little panda sleep animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 12; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"littlePandaSleep_%i", i]]];
    }
    self.littlePandaSleep = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    //Creat little panda move animation
    textures = [NSMutableArray new];
    for (int i = 1; i <= 3; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"littlePandaMove_0%i", i]]];
    }
    self.littlePandaMove = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.2]];
    
    //Create camera
    SKNode *panda = [self childNodeWithName:@"Panda"];
    [panda runAction:self.idleAnimation withKey:@"StayAnimation"];
    
    
    camera = (SKCameraNode *)[self childNodeWithName:@"MainCamera"];
    id horizConstraint = [SKConstraint distance:[SKRange rangeWithUpperLimit:0] toNode:panda];
    id vertConstraint = [SKConstraint distance:[SKRange rangeWithUpperLimit:0] toNode:panda];
    id leftConstraint = [SKConstraint positionX:[SKRange rangeWithLowerLimit:camera.position.x]];
    id bottomConstraint = [SKConstraint positionY:[SKRange rangeWithLowerLimit:camera.position.y]];
    id rightConstraint = [SKConstraint positionX:[SKRange rangeWithUpperLimit:(exitSign.position.x + 200 - camera.position.x)]];
    id topConstraint = [SKConstraint positionY:[SKRange rangeWithUpperLimit:(_background.frame.size.height - 10 - camera.position.y)]];
    [camera setConstraints:@[horizConstraint, vertConstraint, leftConstraint, bottomConstraint, rightConstraint, topConstraint]];
    //lastCameraPosition = camera.position.x;
    
    //Add moving buttons to screen
    //left move button
    leftMoveButton = [SKSpriteNode spriteNodeWithImageNamed:@"leftbutton"];
    leftMoveButton.alpha = 0.5;
    leftMoveButton.scale = 0.7;
    leftMoveButton.position = CGPointMake(-440, -228);
    leftMoveButton.zPosition = 20;
    leftMoveButton.name = @"leftMoveButton";
    [camera addChild:leftMoveButton];
    //right move button
    rightMoveButton = [SKSpriteNode spriteNodeWithImageNamed:@"rightbutton"];
    rightMoveButton.alpha = 0.5;
    rightMoveButton.scale = 0.7;
    rightMoveButton.position = CGPointMake(-280, -228);
    rightMoveButton.zPosition = 20;
    rightMoveButton.name = @"rightMoveButton";
    [camera addChild:rightMoveButton];
    //jump button
    jumpButton = [SKSpriteNode spriteNodeWithImageNamed:@"jumpbutton"];
    jumpButton.alpha = 0.5;
    jumpButton.scale = 0.7;
    jumpButton.position = CGPointMake(440, -228);
    jumpButton.zPosition = 20;
    jumpButton.name = @"jumpButton";
    [camera addChild:jumpButton];
    
    
    
    //End game button
    endGame = [SKSpriteNode spriteNodeWithImageNamed:@"okbutton"];
    endGame.size = CGSizeMake(91, 95);
    endGame.position = CGPointMake(440, 230);
    endGame.name = @"endGame";
    [camera addChild:endGame];

    if ([KKGameData sharedGameData].numberOfLives == 0) {
        [KKGameData sharedGameData].numberOfLives = 3;
    }
    //Score
    [self setupHUD];
    _score.text = [NSString stringWithFormat:@"%li", [KKGameData sharedGameData].totalScore];
    _time.text = @"00:00";
    
    
    //Setup array of coins
    coins = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"coin"]) {
            [child runAction:self.coinAnimation withKey:@"CoinAnimation"];
            [coins addObject:child];
        }
    }
    
    //Setup array of pickUpHearts
    pickUpHearts = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"heart"]) {
            [pickUpHearts addObject:child];
        }
    }
    
    //Setup array of pickUpClocks
    pickUpClocks = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"clock"]) {
            [pickUpClocks addObject:child];
        }
    }
    
    //Setup array of pickUpStars
    pickUpStars = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"star"]) {
            [pickUpStars addObject:child];
        }
    }
    
    //Setup array of blue snails
    bluesnails = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"bluesnail"]) {
            [child runAction:self.blueSnailIdleAnimation withKey:@"BlueSnailIdleAnimation"];
            [child setPhysicsBody:nil];
            [bluesnails addObject:child];
        }
    }
    
    //Setup array of red snails
    redsnails = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"redsnail"]) {
            [child runAction:self.redSnailIdleAnimation withKey:@"RedSnailIdleAnimation"];
            [child setPhysicsBody:nil];
            [redsnails addObject:child];
        }
    }
    
    //Setup array of mushrooms
    mushrooms = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"mushroom"]) {
            [child runAction:self.mushroomIdleAnimation withKey:@"MushroomIdleAnimation"];
            [child setPhysicsBody:nil];
            [mushrooms addObject:child];
        }
    }
    
    //Setup array of flowers
    flowers = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"flower"]) {
            
            [child runAction:self.flowerIdleAnimation withKey:@"FlowerIdleAnimation"];
            [child setPhysicsBody:nil];
            [flowers addObject:child];
        }
    }
    flowersSpit = [NSMutableArray new];
    
    //Setup array of little pandas
    littlePandas = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"littlePandaEat"] || [child.name isEqualToString:@"littlePandaSleep"] || [child.name isEqualToString:@"littlePandaMove"]) {
            
            [child setPhysicsBody:nil];
            [littlePandas addObject:child];
            
            if ([child.name isEqualToString:@"littlePandaEat"]) {
                [child runAction:self.littlePandaEat withKey:@"LittlePandaEatAnimation"];
            }
            else if ([child.name isEqualToString:@"littlePandaSleep"]) {
                [child runAction:self.littlePandaSleep withKey:@"LittlePandaSleepAnimation"];
            }
            else {
                [child runAction:self.littlePandaMove withKey:@"LittlePandaMoveAnimation"];
                //NSNumber *k = [NSNumber numberWithFloat:child.position.x];
                //[littlePandasMoveStartPosition addObject:k];
            }
        }
    }
    
    littlePandasMoveStartPosition = [NSMutableArray new];
    littlePandasMoving = [NSMutableArray new];
    int i = 0;
    for (SKSpriteNode *panda in littlePandas) {
        if ([panda.name isEqualToString:@"littlePandaMove"]) {
            [littlePandasMoving insertObject:panda atIndex:i];
            
            NSNumber *k = [NSNumber numberWithFloat:panda.position.x];
            [littlePandasMoveStartPosition insertObject:k atIndex:i];
            i++;
        }
    }
    
    //Setup array of borders
    borders = [NSMutableArray new];
    for (SKSpriteNode *child in [self children]) {
        if ([child.name isEqualToString:@"border"]) {
            [borders addObject:child];
        }
    }
    
    
    
}

//Score
SKLabelNode* _score;
SKLabelNode* _time;

-(void)setupHUD
{
    _score = [[SKLabelNode alloc] initWithFontNamed:@"MarkerFelt-Wide"];
    _score.fontSize = 30.0;
    _score.position = CGPointMake(-497, 155);
    _score.fontColor = [SKColor blackColor];
    _score.zPosition = 1000;
    _score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [camera addChild:_score];
    
    SKSpriteNode *clock = [SKSpriteNode spriteNodeWithImageNamed:@"clock"];
    clock.position = CGPointMake(-480, 215);
    clock.zPosition = 1000;
    clock.name = [NSString stringWithFormat:@"clock"];
    clock.scale = 0.5;
    [camera addChild:clock];
    _time = [[SKLabelNode alloc] initWithFontNamed:@"MarkerFelt-Wide"];
    _time.fontSize = 30.0;
    _time.position = CGPointMake(-445, 203);
    _time.zPosition = 1000;
    _time.fontColor = [SKColor blueColor];
    _time.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [camera addChild:_time];
    
    //heart's nodes
    hearts = [NSMutableArray new];
    for (int i = 0; i < [KKGameData sharedGameData].numberOfLives; i++) {
        SKSpriteNode *heart = [SKSpriteNode spriteNodeWithImageNamed:@"hud_heartFull"];
        heart.position = CGPointMake(-480 + i*50, 265);
        heart.zPosition = 1000;
        heart.name = [NSString stringWithFormat:@"heart%i",i];
        heart.scale = 0.8;
        [camera addChild:heart];
        [hearts insertObject:heart atIndex:i];
    }
}

- (void)updateScoreHUD {
    _score.text = [NSString stringWithFormat:@"%li", [KKGameData sharedGameData].score + [KKGameData sharedGameData].totalScore];
    SKAction *labelMoveIn = [SKAction scaleTo:1.2 duration:0.2];
    SKAction *labelMoveOut = [SKAction scaleTo:1.0 duration:0.2];
    [_score runAction:[SKAction sequence:@[labelMoveIn, labelMoveOut]]];
}

- (void)updateHeartsHUD {
    //update hearts
    if ([KKGameData sharedGameData].numberOfLives < [hearts count]) {
//        SKSpriteNode *emptyHeart = [SKSpriteNode spriteNodeWithImageNamed:@"hud_heartEmpty"];
//        emptyHeart.position = hearts[[hearts count] - 1].position;
//        emptyHeart.scale = 0.8;
//        [camera addChild:emptyHeart];
//        [hearts[[hearts count] - 1] removeFromParent];
//        [hearts removeObject:hearts[[hearts count] - 1]];
        [hearts[[KKGameData sharedGameData].numberOfLives] setTexture:[SKTexture textureWithImageNamed:@"hud_heartEmpty"]];
    }
}

- (void)playSoundNamed:(NSString *)soundName ofType:(NSString *)soundType {
    for (int i = 0; i < [soundsArray count]; i++) {
        if (![soundsArray[i] isPlaying]) {
            [soundsArray removeObject:soundsArray[i]];
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:soundType];
    sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    sound.volume = [KKGameData sharedGameData].soundVolume;
    sound.numberOfLoops = 0;
    [sound prepareToPlay];
    [sound play];
    [soundsArray addObject:sound];
    
}


const int kMoveSpeed = 200;
static const NSTimeInterval kHugeTime = 9999.0;

BOOL isLeftMoveButton;
BOOL isRightMoveButton;
BOOL isJumpButton;


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    SKNode *panda = [self childNodeWithName:@"Panda"];
    //[panda runAction:self.idleAnimation withKey:@"StayAnimation"];
    

    
    CGPoint touchLocation = [[touches anyObject] locationInNode:self];
    SKSpriteNode *node = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
    if (!isPandaFall && !isDieAnimation && !isExit) {
        if ([node.name isEqualToString:@"jumpButton"]) {
            //Jump
            
            [jumpButton setTexture:[SKTexture textureWithImageNamed:@"greenjumpbutton"]];
            
            isJumpButton = YES;
            isPandaJump = YES;
            SKAction *jumpMove = [SKAction applyImpulse:CGVectorMake(0, 200) duration:0.1];
            //[panda.physicsBody setAccessibilityFrame:CGRectMake(panda.position.x, panda.position.y, 125, 222)];
            //[panda removeActionForKey:@"StayAnimation"];
            [panda runAction:[SKAction sequence:@[jumpMove, self.jumpAnimation]] completion:^{
                if (isLeftMoveButton == YES || isRightMoveButton == YES) {
                    [panda runAction:self.runAnimation withKey:@"MoveAnimation"];
                }
                isPandaJump = NO;
                //[panda removeAllActions];
                //[panda runAction:self.idleAnimation withKey:@"StayAnimation"];
            }];
        }
        
        if ([node.name isEqualToString:@"leftMoveButton"]) {
            
            [leftMoveButton setTexture:[SKTexture textureWithImageNamed:@"greenleftbutton"]];
            
            //left move
            isLeftMoveButton = YES;
            panda.xScale = -1.0*ABS(panda.xScale);
            //SKAction *leftMove = [SKAction applyForce:CGVectorMake(-150, 0) duration:kHugeTime];
            //[panda runAction:leftMove withKey:@"MoveAction"];
            panda.position = CGPointMake(panda.position.x - 5, panda.position.y);
            [panda runAction:self.runAnimation withKey:@"MoveAnimation"];
            
        }
        if ([node.name isEqualToString:@"rightMoveButton"]) {
            
            [rightMoveButton setTexture:[SKTexture textureWithImageNamed:@"greenrightbutton"]];
            
            //right move
            isRightMoveButton = YES;
            panda.xScale = 1.0*ABS(panda.xScale);
            //SKAction *rightMove = [SKAction applyForce:CGVectorMake(150, 0) duration:kHugeTime];
            //[panda runAction:rightMove withKey:@"MoveAction"];
            panda.position = CGPointMake(panda.position.x + 5, panda.position.y);
            [panda runAction:self.runAnimation withKey:@"MoveAnimation"];
        }
    }
    
    
    //Touch end button DELETE
    //CGPoint touchLocation = [[touches anyObject] locationInNode:self];
    //SKSpriteNode *node = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    if ([node.name isEqualToString:@"endGame"]) {
        isExit = YES;
        [self endLevel:kEndReasonWin];
    }
    
    if ([node.name isEqualToString:@"homebutton"] || [node.name isEqualToString:@"levelsbutton"] || [node.name isEqualToString:@"restartbutton"] || [node.name isEqualToString:@"playbutton"]) {
        
        
        
        SKView * skView = (SKView *)self.view;
        MenuScenesController *scene = [MenuScenesController new];
        if ([node.name isEqualToString:@"homebutton"]) {
            [[[GameViewController alloc]init]playMenuBackgroundMusic];
            scene = [MenuScenesController nodeWithFileNamed:@"GameStart"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [skView presentScene:scene];
        }
        else if ([node.name isEqualToString:@"levelsbutton"]) {
            [[[GameViewController alloc]init]playMenuBackgroundMusic];
            scene = [MenuScenesController nodeWithFileNamed:@"GameLevels"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [skView presentScene:scene];
        }
        else if ([node.name isEqualToString:@"playbutton"]) {
            GameScene *gameScene = [GameScene nodeWithFileNamed:[NSString stringWithFormat:@"Level%iScene", level + 1]];
            
            [KKGameData sharedGameData].currentLevel = level + 1;
            [[KKGameData sharedGameData] save];
            
            NSLog(@"completeLevels %i", [KKGameData sharedGameData].completeLevels);
            NSLog(@"currentLevel %i", [KKGameData sharedGameData].currentLevel);

            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            [skView presentScene:gameScene];
        }
        else if ([node.name isEqualToString:@"restartbutton"]) {
            GameScene *gameScene = [GameScene nodeWithFileNamed:[NSString stringWithFormat:@"Level%iScene", level]];
            
            [KKGameData sharedGameData].currentLevel = level;
            [[KKGameData sharedGameData] save];
            
            NSLog(@"completeLevels %i", [KKGameData sharedGameData].completeLevels);
            NSLog(@"currentLevel %i", [KKGameData sharedGameData].currentLevel);
            
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            [skView presentScene:gameScene];
        }
    }

}



- (void)reduceTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    //SKNode *panda = [self childNodeWithName:@"Panda"];
    
    
    //CGPoint touchLocation = [[touches anyObject] locationInNode:self];
    //SKSpriteNode *node = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
    //moveTouches = 0;
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKNode *panda = [self childNodeWithName:@"Panda"];

    [super touchesEnded:touches withEvent:event];
    [self reduceTouches:touches withEvent:event];
    
    if ((isLeftMoveButton == YES || isRightMoveButton == YES) && isJumpButton != YES) {
        [panda removeActionForKey:@"MoveAction"];
        [panda removeActionForKey:@"MoveAnimation"];
        [panda runAction:self.idleAnimation withKey:@"StayAnimation"];
        
        isLeftMoveButton = NO;
        isRightMoveButton = NO;
        
        [leftMoveButton setTexture:[SKTexture textureWithImageNamed:@"leftbutton"]];
        [rightMoveButton setTexture:[SKTexture textureWithImageNamed:@"rightbutton"]];
    }
    
    if (isJumpButton == YES) {
        
        [jumpButton setTexture:[SKTexture textureWithImageNamed:@"jumpbutton"]];
        
        isJumpButton = NO;
        if (isRightMoveButton != YES && isLeftMoveButton != YES) {
            [panda runAction:self.idleAnimation withKey:@"StayAnimation"];

        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self reduceTouches:touches withEvent:event];
    
    
}

- (void)willMoveFromView:(SKView *)view {
    [super willMoveFromView:view];
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

- (void)littlePandasMove {
    for (int i = 0; i < [littlePandasMoving count]; i++) {
        if (littlePandasMoving[i].xScale > 0) {
            if (littlePandasMoving[i].position.x >= [[littlePandasMoveStartPosition objectAtIndex:i] floatValue] - 40) {
                littlePandasMoving[i].position = CGPointMake(littlePandasMoving[i].position.x - 1, littlePandasMoving[i].position.y);
            }
            else {
                littlePandasMoving[i].xScale = -1.0*ABS(littlePandasMoving[i].xScale);
            }
        }
        else {
            if (littlePandasMoving[i].position.x <= [[littlePandasMoveStartPosition objectAtIndex:i] floatValue] + 40) {
                littlePandasMoving[i].position = CGPointMake(littlePandasMoving[i].position.x + 1, littlePandasMoving[i].position.y);
            }
            else {
                littlePandasMoving[i].xScale = 1.0*ABS(littlePandasMoving[i].xScale);
            }
        }
    }
}



- (void)pandaFallinWater {
    SKNode *panda = [self childNodeWithName:@"Panda"];
    if ([panda intersectsNode:[self childNodeWithName:@"water"]] && panda.position.y <= 150) {
        
        if (!isPandaFall) {
            
            for (int i = 0; i < [hearts count];i++) {
                [hearts[i] setTexture:[SKTexture textureWithImageNamed:@"hud_heartEmpty"]];
            }
            
            [backgroundGameMusic stop];
            [self playSoundNamed:@"lose_sound" ofType:@"mp3"];
            panda.physicsBody = nil;
            SKAction *jumpFallUp = [SKAction moveTo:CGPointMake(panda.position.x, panda.position.y + 200) duration:0.3];
            SKAction *jumpFallDown = [SKAction moveTo:CGPointMake(panda.position.x, panda.position.y - 150) duration:0.3];
            //SKAction *fadeOutUp = [SKAction fadeAlphaTo:0.7 duration:0.35];
            //SKAction *fadeOutDown = [SKAction fadeAlphaTo:0.2 duration:0.35];
            [panda runAction:[SKAction sequence:@[jumpFallUp,[SKAction waitForDuration:1]]] completion:^{
                [panda runAction:[SKAction sequence:@[jumpFallDown]] completion:^{
                    [self endLevel:kEndReasonLose];
                }];
            }];
        }
        
        isPandaFall = YES;
        
        
//        SKAction *jumpMove = [SKAction applyImpulse:CGVectorMake(0, 30) duration:0.15];
//        [panda runAction:[SKAction sequence:@[jumpMove, self.jumpAnimation]] completion:^{
//            [self endLevel:kEndReasonLose];
//        }];
    }
}

- (void)saveLittlePandas {
    SKNode *panda = [self childNodeWithName:@"Panda"];
    
    for (int i = 0; i < [littlePandas count]; i++) {
        if ([panda intersectsNode:littlePandas[i]]) {
            [self playSoundNamed:@"pickupheart" ofType:@"wav"];

            [KKGameData sharedGameData].score += 10000;
            [self updateScoreHUD];
            [littlePandas[i] removeFromParent];
            [littlePandas[i] removeAllActions];
            [littlePandas removeObject:littlePandas[i]];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    [super update:currentTime]; //Calls the Visualiser
    
    [self saveLittlePandas];
    
    [self pandaFallinWater];
    
    [self littlePandasMove];
    
    //[self updateHUD];
    
    SKNode *panda = [self childNodeWithName:@"Panda"];
    
    if (!isPandaFall && !isDieAnimation) {
        if (isLeftMoveButton == YES) {
            panda.position = CGPointMake(panda.position.x - 5, panda.position.y);
        }
        if (isRightMoveButton == YES) {
            panda.position = CGPointMake(panda.position.x + 5, panda.position.y);
        }
    }
    
    
    if ([KKGameData sharedGameData].isAccelerometerON == YES) {
        [self accelerometerUpdate];
    }
    
    // Score for coins
    //SKSpriteNode *coin = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"coin"]];
    for (int i = 0; i < [coins count]; i++) {
        if ([panda intersectsNode:coins[i]]) {
            [self playSoundNamed:@"coin" ofType:@"wav"];
            [KKGameData sharedGameData].score += 100;
            [self updateScoreHUD];
            [self removeChildrenInArray:[NSArray arrayWithObjects:coins[i], nil]];
            [coins[i] removeAllActions];
            [coins removeObject:coins[i]];
        }
    }
    
    //Pick Up Hearts
    for (int i = 0; i < [pickUpHearts count]; i++) {
        if ([panda intersectsNode:pickUpHearts[i]]) {
            [self playSoundNamed:@"pickupheart" ofType:@"wav"];
            [KKGameData sharedGameData].score += 1000;
            [self updateScoreHUD];
            
            if ([KKGameData sharedGameData].numberOfLives < 3) {
                [KKGameData sharedGameData].numberOfLives++;
//                SKSpriteNode *heart = [SKSpriteNode spriteNodeWithImageNamed:@"hud_heartFull"];
//                heart.position = CGPointMake(-480 + ([KKGameData sharedGameData].numberOfLives - 1)*50, 350);
//                heart.zPosition = 1000;
//                heart.name = [NSString stringWithFormat:@"heart%i",[KKGameData sharedGameData].numberOfLives - 1];
//                heart.scale = 0.8;
//                [camera addChild:heart];
//                [hearts insertObject:heart atIndex:[KKGameData sharedGameData].numberOfLives - 1];
                [hearts[[KKGameData sharedGameData].numberOfLives - 1] setTexture:
                                                                    [SKTexture textureWithImageNamed:@"hud_heartFull"]];

            }

            
            [self removeChildrenInArray:[NSArray arrayWithObjects:pickUpHearts[i], nil]];
            [pickUpHearts removeObject:pickUpHearts[i]];
        }
    }
    
    //Pick Up Clocks
    for (int i = 0; i < [pickUpClocks count]; i++) {
        if ([panda intersectsNode:pickUpClocks[i]]) {
            [self playSoundNamed:@"pickupheart" ofType:@"wav"];
            [KKGameData sharedGameData].score += 500;
            [self updateScoreHUD];
            
            [KKGameData sharedGameData].time -= 5;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"mm:ss"];
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[KKGameData sharedGameData].time];
            
            _time.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
            SKAction *labelMoveIn = [SKAction scaleTo:1.2 duration:0.2];
            SKAction *labelMoveOut = [SKAction scaleTo:1.0 duration:0.2];
            [_time runAction:[SKAction sequence:@[labelMoveIn, labelMoveOut]]];
            
            [self removeChildrenInArray:[NSArray arrayWithObjects:pickUpClocks[i], nil]];
            [pickUpClocks removeObject:pickUpClocks[i]];
        }
    }
    
    //Pick Up Stars
    for (int i = 0; i < [pickUpStars count]; i++) {
        if ([panda intersectsNode:pickUpStars[i]]) {
            [self playSoundNamed:@"pickupheart" ofType:@"wav"];
            [KKGameData sharedGameData].score += 2000;
            [self updateScoreHUD];
            
            //Animation for picked star
            NSMutableArray *textures = [NSMutableArray new];
            for (int i = 1; i <= 6; i++) {
                [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"star0%i",i]]];
            }
            SKAction *starAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
            
            SKSpriteNode *pickedStar = [SKSpriteNode spriteNodeWithImageNamed:@"star01"];
            pickedStar.position = pickUpStars[i].position;
            pickedStar.zPosition = 5;
            [self addChild:pickedStar];
            [pickedStar runAction:starAnimation completion:^{
                [pickedStar removeFromParent];
            }];
            
            [self removeChildrenInArray:[NSArray arrayWithObjects:pickUpStars[i], nil]];
            [pickUpStars removeObject:pickUpStars[i]];
        }
    }
    
    
    //Score for times
    static NSTimeInterval _lastCurrentTime = 0;
    if (currentTime-_lastCurrentTime>1 && !isDieAnimation &&!isPandaFall && !isExit) {
        [KKGameData sharedGameData].time++;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm:ss"];
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[KKGameData sharedGameData].time];
        
        _time.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
        _lastCurrentTime = currentTime;
    }
    
    
    //Move score label when camera moves
    
    //NSLog(@"%f", camera.position.x);
    //NSLog(@"%f\n\n", lastCameraPosition);

  /*  if (lastCameraPosition < camera.position.x) {
        //_score.position = CGPointMake(_score.position.x + (camera.position.x - lastCameraPosition), _score.position.y);
        
        
//        [_score runAction:[SKAction moveTo:CGPointMake(camera.position.x - 362, 130) duration:0.1] completion:^{
//            [_score removeAllActions];
//        }];
        //[_score runAction:[SKAction moveTo:CGPointMake(camera.position.x - 362, 130) duration:0.5] withKey:@"ScoreMove"];
        

        
        _time.position = CGPointMake(_time.position.x + (camera.position.x - lastCameraPosition), _time.position.y);
        endGame.position = CGPointMake(endGame.position.x + (camera.position.x - lastCameraPosition), endGame.position.y);
        leftMoveButton.position = CGPointMake(leftMoveButton.position.x + (camera.position.x - lastCameraPosition), leftMoveButton.position.y);
        rightMoveButton.position = CGPointMake(rightMoveButton.position.x + (camera.position.x - lastCameraPosition), rightMoveButton.position.y);
        jumpButton.position = CGPointMake(jumpButton.position.x + (camera.position.x - lastCameraPosition), jumpButton.position.y);
    }
    else if ((lastCameraPosition > camera.position.x) && (lastCameraPosition >= 150)) {
        if (lastCameraPosition >= 500) {
            endGame.position = CGPointMake(endGame.position.x - (lastCameraPosition - camera.position.x), endGame.position.y);
            jumpButton.position = CGPointMake(jumpButton.position.x + (camera.position.x - lastCameraPosition),
                                              jumpButton.position.y);
        }
        _score.position = CGPointMake(_score.position.x - (lastCameraPosition - camera.position.x), _score.position.y);
        _time.position = CGPointMake(_time.position.x - (lastCameraPosition - camera.position.x), _time.position.y);
        leftMoveButton.position = CGPointMake(leftMoveButton.position.x + (camera.position.x - lastCameraPosition), leftMoveButton.position.y);
        rightMoveButton.position = CGPointMake(rightMoveButton.position.x + (camera.position.x - lastCameraPosition), rightMoveButton.position.y);
    } */
    
    
    [self exit];
    
    [self enemies:bluesnails withIdleAnimationKey:@"BlueSnailIdleAnimation" withHurtAnimation:self.blueSnailHurtAnimation];
    [self enemies:redsnails withIdleAnimationKey:@"RedSnailIdleAnimation" withHurtAnimation:self.redSnailHurtAnimation];
    [self enemies:mushrooms withIdleAnimationKey:@"MushroomIdleAnimation" withHurtAnimation:self.mushroomHurtAnimation];
    [self flowersEnemies];

    if (!isExit) {
        [self spitMovingUpdate];
    }
    else {
        for (int i = 0; i < [flowersSpit count]; i++) {
            [flowersSpit[i] removeFromParent];
        }
    }
    
    //lastCameraPosition = camera.position.x;
}

BOOL isDieAnimation;

- (void)pandaHurts {
    if ([KKGameData sharedGameData].numberOfLives > 0) {
        SKSpriteNode *panda = (SKSpriteNode *)[self childNodeWithName:@"Panda"];
        isDieAnimation = NO;
        
        //play "oops" sound
        [self playSoundNamed:@"oops" ofType:@"wav"];
        
        [KKGameData sharedGameData].numberOfLives--;
        [self updateHeartsHUD];
        
        //NSLog(@"%i",[KKGameData sharedGameData].numberOfLives);
        if ([KKGameData sharedGameData].numberOfLives == 0) {
            
            isDieAnimation = YES;
            
            if (isLeftMoveButton) {
                isLeftMoveButton = NO;
                [leftMoveButton setTexture:[SKTexture textureWithImageNamed:@"leftbutton"]];
            }
            if (isRightMoveButton) {
                isRightMoveButton = NO;
                [rightMoveButton setTexture:[SKTexture textureWithImageNamed:@"rightbutton"]];
            }
            if (isJumpButton) {
                isJumpButton = NO;
                [jumpButton setTexture:[SKTexture textureWithImageNamed:@"jumpbutton"]];
            }
            
            [backgroundGameMusic stop];
            [self playSoundNamed:@"lose_sound" ofType:@"mp3"];

            [panda runAction:self.dieAnimation completion:^{
                //[panda removeFromParent];
                panda.alpha = 0.0;
                [self endLevel:kEndReasonLose];
            }];
            
        }
        
        if (!isDieAnimation) {
            isHurtAnimationRunning = YES;
            [panda runAction:self.hurtAnimation completion:^{
                isHurtAnimationRunning = NO;
            }];
            
            if (isLeftMoveButton == YES || isRightMoveButton == YES || isJumpButton == YES) {
                [panda runAction:self.runAnimation withKey:@"MoveAnimation"];
            }
        }
        
    }
}

- (void)enemies:(NSMutableArray<SKSpriteNode *> *)enemiesArray withIdleAnimationKey:(NSString *)idleAnimationKey withHurtAnimation:(SKAction *)hurtAnimation {
    SKSpriteNode *panda = (SKSpriteNode *)[self childNodeWithName:@"Panda"];
    for (int i = 0; i < [enemiesArray count]; i++) {
        for (int k = 0; k < [borders count]; k++) {
            
            if ([enemiesArray[i] intersectsNode:borders[k]]) {

                if (enemiesArray[i].xScale < 0) {
                    enemiesArray[i].xScale = 1.0*ABS(enemiesArray[i].xScale);
                }
                else if (enemiesArray[i].xScale > 0) {
                    enemiesArray[i].xScale = -1.0*ABS(enemiesArray[i].xScale);
                }
            }
            
            if ([enemiesArray[i] intersectsNode:panda] && CGRectGetMinX(panda.frame) <= CGRectGetMaxX(enemiesArray[i].frame) && CGRectGetMaxX(panda.frame) >= CGRectGetMinX(enemiesArray[i].frame) && (CGRectGetMinY(enemiesArray[i].frame) - CGRectGetMinY(panda.frame) <= 3 && CGRectGetMinY(enemiesArray[i].frame) - CGRectGetMinY(panda.frame) >= -3)) {
                
                if ((enemiesArray[i].xScale < 0 && (panda.xScale < 0)) || (panda.xScale > 0 && panda.position.x > enemiesArray[i].position.x)) {
                    
                    enemiesArray[i].xScale = 1.0*ABS(enemiesArray[i].xScale);
                }
                else if ((enemiesArray[i].xScale > 0 && panda.xScale > 0) || (panda.xScale < 0 && panda.position.x < enemiesArray[i].position.x)) {
                    
                    enemiesArray[i].xScale = -1.0*ABS(enemiesArray[i].xScale);
                }
                
                if (!isHurtAnimationRunning && !isDieAnimation) {
                    [self pandaHurts];
                }
                
            }
            
            //NSLog(@"%f - %f, %f - %f", CGRectGetMinY(panda.frame), CGRectGetMinY(enemiesArray[i].frame), CGRectGetMinY(panda.frame), CGRectGetMaxY(enemiesArray[i].frame));
            
            //Killing enemy
            if ([enemiesArray[i] intersectsNode:panda] && CGRectGetMinY(panda.frame) >= CGRectGetMinY(enemiesArray[i].frame) + 20 && CGRectGetMinY(panda.frame) <= CGRectGetMaxY(enemiesArray[i].frame)) {
                
                [self playSoundNamed:@"jumpland" ofType:@"wav"];
                
                if (isPandaJump == NO) {
                    //[panda.physicsBody setAccessibilityFrame:CGRectMake(panda.position.x, panda.position.y, 72, 85)];
                    SKAction *up = [SKAction moveByX:0 y:panda.frame.origin.y + 300 duration:0.4];
                    SKAction *down = [SKAction moveByX:0 y:panda.frame.origin.y - 300 duration:0.4];
                    SKAction *jumpMove = [SKAction sequence:@[up, down, self.jumpAnimation]];
                    [panda removeActionForKey:@"StayAnimation"];
                    [panda runAction:jumpMove completion:^{
                        if (isLeftMoveButton != YES && isRightMoveButton != YES) {
                            //[panda runAction:self.idleAnimation withKey:@"StayAnimation"];
                        }
                    }];
                }
                
                
                [enemiesArray[i] removeActionForKey:idleAnimationKey];
                
                SKSpriteNode *tempSnail = [SKSpriteNode new];
                tempSnail = enemiesArray[i];
                [enemiesArray removeObject:enemiesArray[i]];
                [KKGameData sharedGameData].score += 1000;
                [self updateScoreHUD];
                [tempSnail setPhysicsBody:NULL];
                [tempSnail runAction:hurtAnimation completion:^{
                    [tempSnail removeFromParent];
                    [tempSnail removeAllActions];
                }];
                
                
                
                break;
            }
            if (enemiesArray[i].xScale < 0) {
                //Right move
                enemiesArray[i].position = CGPointMake(enemiesArray[i].position.x + 0.40, enemiesArray[i].position.y);
            }
            else {
                //Left move
                enemiesArray[i].position = CGPointMake(enemiesArray[i].position.x - 0.40, enemiesArray[i].position.y);
            }
        }
    }
}

BOOL isFlowerAttackAnimation;

- (SKAction *) attackAnimationForFlower:(SKSpriteNode *)flower {
    //Create flower attack animation
    NSMutableArray *textures = [NSMutableArray new];
    for (int i = 1; i <= 9; i++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"flowerattack_0%i", i]]];
    }
    SKSpriteNode *spit = [SKSpriteNode spriteNodeWithImageNamed:@"flowersspit"];
    if (flower.xScale >= 0) {
        spit.position = CGPointMake(flower.position.x + 70, flower.position.y - 10);
    }
    else {
        spit.position = CGPointMake(flower.position.x - 50, flower.position.y - 10);
    }
    spit.zPosition = 3;
    spit.alpha = 0;
    spit.xScale = flower.xScale;
    [self addChild:spit];
    [self playSoundNamed:@"spitting" ofType:@"wav"];
    [spit runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5f], [SKAction fadeAlphaTo:1 duration:0.0f]]]];
    
    self.flowerAttackAnimation = [SKAction sequence:@[[SKAction repeatAction:[SKAction animateWithTextures:textures timePerFrame:0.1] count:1], [SKAction waitForDuration:2.0f]]];
    
    [flowersSpit addObject:spit];
    
    return self.flowerAttackAnimation;
}

- (void)spitMovingUpdate {
    SKSpriteNode *panda = (SKSpriteNode *)[self childNodeWithName:@"Panda"];

    for (int i = 0; i < [flowersSpit count]; i++) {
        //NSLog(@"%f", flowersSpit[i].position.x);
        //Moving spits
        if (flowersSpit[i].xScale > 0) {
            flowersSpit[i].position = CGPointMake(flowersSpit[i].position.x - 5, flowersSpit[i].position.y);
        }
        else {
            flowersSpit[i].position = CGPointMake(flowersSpit[i].position.x + 5, flowersSpit[i].position.y);
        }
        
        //Intersecting spit with panda
        if ([panda intersectsNode:flowersSpit[i]] && !isHurtAnimationRunning &&!isDieAnimation) {
            [self pandaHurts];
        }
        
        //Delete spits
        if (flowersSpit[i].position.x <= -200 || flowersSpit[i].position.x >= exitSign.position.x + 400) {
            [flowersSpit removeObject:flowersSpit[i]];
        }
    }
}

- (void)flowersEnemies {
    SKSpriteNode *panda = (SKSpriteNode *)[self childNodeWithName:@"Panda"];
    for (int i = 0; i < [flowers count]; i++) {
        
        
        if (flowers[i].position.x >= camera.position.x - self.frame.size.width/2 && flowers[i].position.x <= camera.position.x + self.frame.size.width/2 && !isFlowerAttackAnimation && !isExit) {
            
            isFlowerAttackAnimation = YES;
            [flowers[i] runAction:[self attackAnimationForFlower:flowers[i]] completion:^{
                isFlowerAttackAnimation = NO;
            }];
        }
        
        if (panda.position.x < flowers[i].position.x) {
            flowers[i].xScale = 1.0*ABS(flowers[i].xScale);
        }
        else {
            flowers[i].xScale = -1.0*ABS(flowers[i].xScale);
        }
        
        //NSLog(@"panda: %f flower: %f", CGRectGetMaxX(panda.frame), CGRectGetMinX(enemiesArray[i].frame));
        //NSLog(@"%i", [flowers[i] intersectsNode:panda]);
        //NSLog(@"%f , %f", CGRectGetMinX(panda.frame), CGRectGetMaxX(flowers[i].frame));
        //NSLog(@"%f", CGRectGetMaxX(panda.frame) - CGRectGetMinX(flowers[i].frame));
        //NSLog(@"%f", CGRectGetMinY(flowers[i].frame) - CGRectGetMinY(panda.frame));
        //NSLog(@"%f", CGRectGetMinY(flowers[i].frame) - CGRectGetMinY(panda.frame));
        //NSLog(@"min camera X = %f, max camera X = %f", camera.position.x - self.frame.size.width/2, camera.position.x + self.frame.size.width/2);
        
        //Intersecting panda and enemy
        if ([flowers[i] intersectsNode:panda] && CGRectGetMinX(panda.frame) <= CGRectGetMaxX(flowers[i].frame) && CGRectGetMaxX(panda.frame) >= CGRectGetMinX(flowers[i].frame) && CGRectGetMaxX(panda.frame) - CGRectGetMinX(flowers[i].frame) >= 20 && (CGRectGetMinY(flowers[i].frame) - CGRectGetMinY(panda.frame) <= 3 && CGRectGetMinY(flowers[i].frame) - CGRectGetMinY(panda.frame) >= -6) && !isHurtAnimationRunning && !isDieAnimation) {
            
            [self pandaHurts];
        }
        
        //Killing enemy
        if ([flowers[i] intersectsNode:panda] && CGRectGetMinY(panda.frame) >= CGRectGetMaxY(flowers[i].frame) - 20 ) {
            
            [self playSoundNamed:@"jumpland" ofType:@"wav"];
            
            SKAction *jumpMove = [SKAction applyImpulse:CGVectorMake(0, 100) duration:0.05];
            //[panda.physicsBody setAccessibilityFrame:CGRectMake(panda.position.x, panda.position.y, 125, 222)];
            [panda removeActionForKey:@"StayAnimation"];
            [panda runAction:jumpMove withKey:@"JumpAction"];
            [panda runAction:self.jumpAnimation withKey:@"JumpAnimation"];
            
            //[flowers[i] removeActionForKey:@"FlowerIdleAnimation"];
            [flowers[i] removeAllActions];
            
            SKSpriteNode *tempSnail = [SKSpriteNode new];
            tempSnail = flowers[i];
            [flowers removeObject:flowers[i]];
            [KKGameData sharedGameData].score += 1000;
            [self updateScoreHUD];
            [tempSnail setPhysicsBody:NULL];
            [tempSnail runAction:self.flowerHurtAnimation completion:^{
                [tempSnail removeFromParent];
                [tempSnail removeAllActions];
            }];
            break;
        }
    }
}

- (void)exit {
    static NSTimeInterval lastCurrentTime = 0;
    SKNode *panda = [self childNodeWithName:@"Panda"];
    SKEmitterNode *particleExit = (SKEmitterNode *)[self childNodeWithName:@"particleExit"];
    if ([littlePandas count] == 0) {
        particleExit.alpha = 1.0;
    }
    else {
        particleExit.alpha = 0.0;
    }
    if (panda.position.x > (particleExit.position.x - 25) && panda.position.x < (particleExit.position.x + 25)) {
        if ([panda actionForKey:@"JumpAnimation"] == nil && [panda actionForKey:@"MoveAnimation"] == nil) {
            lastCurrentTime += 1;
            if (lastCurrentTime >= 30 && !isExit && [littlePandas count] == 0) {
                lastCurrentTime = 0;
                isExit = YES;
                [self playSoundNamed:@"win_sound" ofType:@"wav"];
                [panda runAction:[SKAction waitForDuration:0.8] completion:^{
                    [self endLevel:kEndReasonWin];
                }];
            }
        }
    }
}

- (void)endLevel:(EndReason)endReason {
    
    if (endReason == kEndReasonWin) {
        [KKGameData sharedGameData].totalScore += [KKGameData sharedGameData].score;
        if ([KKGameData sharedGameData].completeLevels == [KKGameData sharedGameData].currentLevel - 1) {
            [KKGameData sharedGameData].completeLevels += 1;
        }
    }
    
    [[KKGameData sharedGameData] save];
    long k = [KKGameData sharedGameData].score;
    long t = [KKGameData sharedGameData].time;
    [[KKGameData sharedGameData] reset];
    
    [backgroundGameMusic stop];
    //[[[GameViewController alloc]init]playMenuBackgroundMusic];
    
    //SKView * skView = (SKView *)self.view;

    if (endReason == kEndReasonWin) {
        
        SKSpriteNode *windowWin = [SKSpriteNode spriteNodeWithImageNamed:@"windowwin"];
        windowWin.zPosition = 1000;
        windowWin.position = CGPointMake(camera.position.x, 410);
        windowWin.scale = 0.8;
        
        SKLabelNode *completeLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        completeLabel.fontSize = 30.0;
        completeLabel.position = CGPointMake(camera.position.x, 598);
        completeLabel.zPosition = 1001;
        completeLabel.fontColor = [SKColor whiteColor];
        completeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        completeLabel.text = @"Level Complete";
        
        SKLabelNode *scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        scoreLabel.fontSize = 32.0;
        scoreLabel.position = CGPointMake(camera.position.x - 108, 360);
        scoreLabel.zPosition = 1001;
        scoreLabel.fontColor = [SKColor blueColor];
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scoreLabel.text = @"Score";
        
        SKLabelNode *totalScoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        totalScoreLabel.fontSize = 32.0;
        totalScoreLabel.position = CGPointMake(camera.position.x + 20, 360);
        totalScoreLabel.zPosition = 1001;
        totalScoreLabel.fontColor = [SKColor whiteColor];
        totalScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        totalScoreLabel.text = [NSString stringWithFormat:@"%ld",k];
        
        SKLabelNode *timeLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        timeLabel.fontSize = 32.0;
        timeLabel.position = CGPointMake(camera.position.x - 108, 280);
        timeLabel.zPosition = 1001;
        timeLabel.fontColor = [SKColor blueColor];
        timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        timeLabel.text = @"Time";
        
        SKSpriteNode *clock = [SKSpriteNode spriteNodeWithImageNamed:@"clock"];
        clock.zPosition = 1000;
        clock.position = CGPointMake(camera.position.x - 14, 290);
        clock.scale = 0.8;
        
        SKLabelNode *timeScoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        timeScoreLabel.fontSize = 32.0;
        timeScoreLabel.position = CGPointMake(camera.position.x + 25, 280);
        timeScoreLabel.zPosition = 1001;
        timeScoreLabel.fontColor = [SKColor whiteColor];
        timeScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm:ss"];
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
        timeScoreLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
        SKSpriteNode *homeButton = [SKSpriteNode spriteNodeWithImageNamed:@"homebutton"];
        homeButton.zPosition = 1001;
        homeButton.position = CGPointMake(camera.position.x - 112, 179);
        homeButton.scale = 0.6;
        homeButton.name = @"homebutton";
        
        SKSpriteNode *levelsButton = [SKSpriteNode spriteNodeWithImageNamed:@"levelsbutton"];
        levelsButton.zPosition = 1001;
        levelsButton.position = CGPointMake(camera.position.x - 2, 179);
        levelsButton.scale = 0.6;
        levelsButton.name = @"levelsbutton";
        
        SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"playbuttonsmall"];
        playButton.zPosition = 1001;
        playButton.position = CGPointMake(camera.position.x + 108, 179);
        playButton.scale = 0.6;
        playButton.name = @"playbutton";
        
        [self addChild:windowWin];
        [self addChild:completeLabel];
        [self addChild:scoreLabel];
        [self addChild:totalScoreLabel];
        [self addChild:timeLabel];
        [self addChild:timeScoreLabel];
        [self addChild:clock];
        [self addChild:homeButton];
        [self addChild:levelsButton];
        [self addChild:playButton];

        if ([pickUpStars count] < 3) {
            SKSpriteNode *star1 = [SKSpriteNode spriteNodeWithImageNamed:@"starsmall"];
            star1.zPosition = 1001;
            star1.position = CGPointMake(camera.position.x - 104.5, 472);
            [self addChild:star1];
            
            if ([pickUpStars count] < 2) {
                SKSpriteNode *star2 = [SKSpriteNode spriteNodeWithImageNamed:@"starbig"];
                star2.zPosition = 1001;
                star2.position = CGPointMake(camera.position.x - 10, 505);
                [self addChild:star2];
                
                if ([pickUpStars count] < 1) {
                    SKSpriteNode *star3 = [SKSpriteNode spriteNodeWithImageNamed:@"starsmall"];
                    star3.zPosition = 1001;
                    star3.position = CGPointMake(camera.position.x + 89, 472);
                    [self addChild:star3];
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        /* MenuScenesController *scene = [MenuScenesController nodeWithFileNamed:@"GameWin"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene]; */
    }
    
    else if (endReason == kEndReasonLose) {
        
        SKSpriteNode *windowLose = [SKSpriteNode spriteNodeWithImageNamed:@"windowlose"];
        windowLose.zPosition = 1000;
        windowLose.position = CGPointMake(camera.position.x, 385);
        windowLose.scale = 0.8;
        
        SKSpriteNode *tapeLose = [SKSpriteNode spriteNodeWithImageNamed:@"tapelose"];
        tapeLose.zPosition = 1001;
        tapeLose.position = CGPointMake(camera.position.x, 591);
        tapeLose.scale = 0.8;
        
        SKLabelNode *failedLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        failedLabel.fontSize = 39.0;
        failedLabel.position = CGPointMake(camera.position.x, 593);
        failedLabel.zPosition = 1002;
        failedLabel.fontColor = [SKColor whiteColor];
        failedLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        failedLabel.text = @"Level Failed";
        
        SKLabelNode *loseLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
        loseLabel.fontSize = 53.0;
        loseLabel.position = CGPointMake(camera.position.x, 394);
        loseLabel.zPosition = 1001;
        loseLabel.fontColor = [SKColor blackColor];
        loseLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        loseLabel.text = @"You Lose";
        
        SKSpriteNode *homeButton = [SKSpriteNode spriteNodeWithImageNamed:@"homebutton"];
        homeButton.zPosition = 1001;
        homeButton.position = CGPointMake(camera.position.x - 112, 183);
        homeButton.scale = 0.6;
        homeButton.name = @"homebutton";
        
        SKSpriteNode *levelsButton = [SKSpriteNode spriteNodeWithImageNamed:@"levelsbutton"];
        levelsButton.zPosition = 1001;
        levelsButton.position = CGPointMake(camera.position.x - 2, 183);
        levelsButton.scale = 0.6;
        levelsButton.name = @"levelsbutton";
        
        SKSpriteNode *restartButton = [SKSpriteNode spriteNodeWithImageNamed:@"restartbutton"];
        restartButton.zPosition = 1001;
        restartButton.position = CGPointMake(camera.position.x + 108, 183);
        restartButton.scale = 0.6;
        restartButton.name = @"restartbutton";
        
        [self addChild:windowLose];
        [self addChild:tapeLose];
        [self addChild:failedLabel];
        [self addChild:loseLabel];
        [self addChild:homeButton];
        [self addChild:levelsButton];
        [self addChild:restartButton];
    }
    
}

- (void)accelerometerUpdate {
    SKNode *panda = [self childNodeWithName:@"Panda"];
    
    /* Set up the motion manager if necessary */
    if (!self.motionManager) {
        self.motionManager = [CMMotionManager new];
        self.motionManager.deviceMotionUpdateInterval = 0.1;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
    
    CMDeviceMotion *motion = self.motionManager.deviceMotion;
    if (motion) {
        CMAttitude *attitude = motion.attitude;
        NSLog(@"%f", attitude.pitch);
        if ((attitude.pitch > -0.2) && (attitude.pitch < 0.0)) {
            panda.xScale = 1.0*ABS(panda.xScale);
            SKAction *rightAccelMove = [SKAction moveBy:CGVectorMake(1.0*kMoveSpeed*kHugeTime, 0) duration:kHugeTime];
            [panda removeActionForKey:@"StayAnimation"];
            [panda runAction:rightAccelMove withKey:@"MoveAction"];
            [panda runAction:self.runAnimation withKey:@"MoveAnimation"];
        }
        else if ((attitude.pitch < 0.2) && (attitude.pitch > 0.0)) {
            panda.xScale = -1.0*ABS(panda.xScale);
            SKAction *leftAccelMove = [SKAction moveBy:CGVectorMake(-1.0*kMoveSpeed*kHugeTime, 0) duration:kHugeTime];
            [panda removeActionForKey:@"StayAnimation"];
            [panda runAction:leftAccelMove withKey:@"MoveAction"];
            [panda runAction:self.runAnimation withKey:@"MoveAnimation"];
        }
        else if ((attitude.pitch < 0.005) && (attitude.pitch > -0.005)) {
            [panda removeActionForKey:@"MoveAnimation"];
            [panda removeActionForKey:@"MoveAction"];
            [panda runAction:self.idleAnimation withKey:@"StayAnimation"];
        }
    }
    else {
        [panda runAction:self.idleAnimation withKey:@"StayAnimation"];
    }
}

@end
