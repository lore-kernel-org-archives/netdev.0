From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Apple Thunderbolt Ethernet device support
Date: Thu, 12 Jul 2012 13:57:06 -0700
Message-ID: <20120712205706.GB27999@kroah.com>
References: <20120712202131.GA26436@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47191 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932911Ab2GLU5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 16:57:13 -0400
Received: by pbbrp8 with SMTP id rp8so4275760pbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 13:57:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120712202131.GA26436@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 01:21:31PM -0700, Greg KH wrote:
> I have an Apple Thunderbolt Ethernet device here, and running 3.5-rc6 it
> isn't detected.  It has PCI id 14e4:1682, which seems like it should be
> supported by the tg3 driver.  Any hints?
> 
> I guess I could just go and add the device id to the driver and see what
> happens...

And that worked, patch sent.

But, as the patch shows, odds are it has a "real" device type in it,
so the #define I used isn't as descriptive as it should be.  Any hints
on how I can figure out what to look at to make it more "correct"?

thanks,

greg k-h
