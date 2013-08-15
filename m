From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate module
 unloading
Date: Thu, 15 Aug 2013 18:54:46 +0200
Message-ID: <520D07D6.70407@linutronix.de>
References: <20130813174814.GE4098@kroah.com> <20130814091946.2643a124@mitra.spranger.biz> <20130814163311.GB7208@kroah.com> <20130815084221.3339142f@mitra.spranger.biz> <20130815065936.GA13320@kroah.com> <20130815092753.5a23810b@mitra.spranger.biz> <20130815080901.GC7080@kroah.com> <520C8EC9.6040603@linutronix.de> <20130815155508.GA14792@kroah.com> <520CFBE0.5070006@linutronix.de> <20130815164227.GC15688@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benedikt Spranger <b.spranger@linutronix.de>,
	netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:35573 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757462Ab3HOQyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 12:54:50 -0400
In-Reply-To: <20130815164227.GC15688@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 06:42 PM, Greg Kroah-Hartman wrote:
>> For this to happen you would need a refcount in uio-core which learns
>> that the device is gone and does not invoke any callbacks because the
>> device is gone. Something like you have in USB where you return 0 on
>> reads from ttyUSB after someone pulled the cable.
> 
> That happens because we invalidate the filehandle in the tty layer by
> tearing everything down in the usb serial driver.  And yes, uio also
> needs to do the same thing, if it doesn't already.

Ah. Do you have a handy pointer where / how you do this?

> 
> thanks,
> 
> greg k-h

Sebastian
