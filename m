From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Apple Thunderbolt Ethernet device support
Date: Thu, 12 Jul 2012 16:18:34 -0700
Message-ID: <20120712231834.GA26823@kroah.com>
References: <20120712202131.GA26436@kroah.com>
 <20120712205706.GB27999@kroah.com>
 <4FFF59A9.4010009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59657 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162597Ab2GLXSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 19:18:39 -0400
Received: by yenl2 with SMTP id l2so3027741yen.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 16:18:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4FFF59A9.4010009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 04:11:37PM -0700, Rick Jones wrote:
> On 07/12/2012 01:57 PM, Greg KH wrote:
> >On Thu, Jul 12, 2012 at 01:21:31PM -0700, Greg KH wrote:
> >>I have an Apple Thunderbolt Ethernet device here, and running 3.5-rc6 it
> >>isn't detected.  It has PCI id 14e4:1682, which seems like it should be
> >>supported by the tg3 driver.  Any hints?
> >>
> >>I guess I could just go and add the device id to the driver and see what
> >>happens...
> >And that worked, patch sent.
> >
> >But, as the patch shows, odds are it has a "real" device type in it,
> >so the #define I used isn't as descriptive as it should be.  Any hints
> >on how I can figure out what to look at to make it more "correct"?
> 
> a long-shot, but maybe there is something in the pci.ids database?

Ah, nice, there is something there:
	1682 NetXtreme BCM57762 Gigabit Ethernet PCIe

I'll redo the patch with that information, thanks.

greg k-h
