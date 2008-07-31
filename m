From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: MV643xx Ethernet Driver Issue on a Motorola PrPMC-275 board.
Date: Thu, 31 Jul 2008 19:48:24 +0200
Message-ID: <20080731174824.GE31160@xi.wantstofly.org>
References: <488F5815.9020402@mvista.com> <20080730235622.GA22826@xi.wantstofly.org> <4891EBE1.3070606@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Larson <clarson@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:32856 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbYGaRs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 13:48:26 -0400
Content-Disposition: inline
In-Reply-To: <4891EBE1.3070606@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 09:44:17AM -0700, Chris Larson wrote:

> >> was wondering if anyone had any advice on an issue a customer of ours 
> >>is running into.  When they run a series of bandwidth tests, slowly 
> >>increasing the bandwidth & # of tcp connections to roughly 30Mbit at 
> >>4000 connections, their machine panics.  An address passed to 
> >>dma_unmap_single is beyond lowmem, as though it was corrupted in some 
> >>fashion.  The address is the data pointer in the ethernet dma 
> >>descriptors, it pulls a descriptor out of the ring in the packet receipt 
> >>functions and at that point the address is wrong.  Nowhere in the driver 
> >>is a descriptor set up with that address, yet the datasheet on the 
> >>mv643xx doesn't seem to indicate that the dma engine ever writes to the 
> >>descriptors themselves, only to the data they point to (as you'd 
> >>expect).  Does anyone have any ideas on this?  I'm afraid that I'm a bit 
> >>out of my depth on this issue.  The architecture is ppc.
> >>    
> >
> >I've never seen this happen.  Which kernel version is this on?
> >  
> One of MontaVista's 2.6.10 trees, too heavily modified to be of much use 
> to you, I'm certain. Most of the recent mv643xx patches are in our tree, 
> as one of our developers was the old maintainer.

Right.  Well, for what it's worth, I've never seen something like this
happening, but I've only tested ARM, and I only started looking at
mv643xx_eth in the ~ 2.6.25 timeframe, so that might not say much.


> It doesn't occur in 2.4, not that that's very helpful :)

That would probably be an entirely different driver, wouldn't it? :)


> I can try to reproduce with a more recent tree and let you know.
> Thanks for your time.

If you can reproduce it, I would certainly be interested if you
could reproduce it on, say, 2.6.25 or later, since those versions
work for me.


thanks,
Lennert
