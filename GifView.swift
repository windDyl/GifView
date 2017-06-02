//
//  GifView.swift
//  ShowGifDemo
//
//  Created by dyLiu on 2017/6/2.
//  Copyright © 2017年 dyLiu. All rights reserved.
//

import UIKit
import ImageIO
import QuartzCore

class GifView: UIView {

    var width:Float{return Float(self.frame.size.width)}
    var height:Float{return Float(self.frame.size.height)}
    
    private var gifUrl:NSURL!
    private var gifImgs:Array<CGImage> = []
    private var timeArray:Array<NSNumber> = []
    private var totalDuration:Float = 0
    
    func showGifWithLocalName(name: String) {
        gifUrl = Bundle.main.url(forResource: name, withExtension: "gif")! as NSURL
        self.createFrame()
    }
    
    func createFrame()  {
        let url:CFURL = gifUrl as CFURL
        let gifSource = CGImageSourceCreateWithURL(url, nil)
        let imgCount = CGImageSourceGetCount(gifSource!)
        for i in 0..<imgCount {
            let imgRef = CGImageSourceCreateImageAtIndex(gifSource!, i, nil)
            gifImgs.append(imgRef!)
            
            let sourceDic = CGImageSourceCopyPropertiesAtIndex(gifSource!, i, nil)! as NSDictionary
            
            let imgW = sourceDic[String(kCGImagePropertyPixelWidth)] as! NSNumber
            let imgH = sourceDic[String(kCGImagePropertyPixelHeight)] as! NSNumber
            if width/height != imgW.floatValue / imgH.floatValue {
                self.fitScaleWAH(imgWidth: Float(imgW), imgHeight: Float(imgH))
            }
            
            let gifDic = sourceDic[String(kCGImagePropertyGIFDictionary)] as! NSDictionary
            let time = gifDic[String(kCGImagePropertyGIFDelayTime)] as! NSNumber
            timeArray.append(time)
            totalDuration += time.floatValue
        }
        self.shaowAnimation()
    }
    func shaowAnimation()  {
        let animation = CAKeyframeAnimation(keyPath: "contents")
        var current:Float = 0
        var timeKeys:Array<NSNumber> = []//
        for time in timeArray {
            timeKeys.append(NSNumber(value:Float(current/totalDuration)))
            current += time.floatValue
        }
        animation.keyTimes = timeKeys
        animation.values = gifImgs
        animation.duration = CFTimeInterval(totalDuration)
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        self.layer.add(animation, forKey: "GifView")
    }
    func fitScaleWAH(imgWidth:Float, imgHeight:Float) {
        var newW:Float
        var newH:Float
        if imgWidth/imgHeight > self.width/self.height {
            newH = imgHeight
            newW = imgHeight * self.width/self.height
        } else {
            newW = imgWidth
            newH = imgWidth * self.height/self.width
        }
        let center:CGPoint = self.center
        self.frame.size = CGSize(width: Double(newW), height: Double(newH))
        self.center = center
    }
    
}
