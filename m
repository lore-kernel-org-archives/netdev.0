From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: transmit lockup using smsc95xx ethernet on usb3
Date: Fri, 18 Oct 2013 08:50:40 -0700
Message-ID: <20131018155040.GA31075@kroah.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B738B@saturn3.aculab.com>
 <20131017000758.GL7082@xanatos>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7394@saturn3.aculab.com>
 <20131017174329.GB6256@xanatos>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7397@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Xenia Ragiadakou <burzalodowa@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:53399 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab3JRPt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:49:27 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7397@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 18, 2013 at 04:22:02PM +0100, David Laight wrote:
> > It's not too hard.  Here's some directions:
> > http://kernelnewbies.org/KernelBuild
> 
> I can build it easily enough but ...
> 
> Is there a .config file with a sane list of modules anywhere?
> (and builtin drivers for disk boot)
> 
> The defconfig one doesn't seem to contain enough to be useful,
> and the allmodconfig gives me 800MB+ to copy from the build
> system to the test one (I can't seem to see an obvious way of
> doing this either - apart from installing them to the 'wrong'
> place on the build system and then copying everything over).

The easiest thing to do is take a working .config file (like created by
your distro, for the kernel it is booting), and creating a smaller
config for just the hardware plugged into the machine at that moment in
time.

You usually do this automatically by running:
	make localmodconfig
which knows how to root around in /proc/config.gz or /boot/ to try to
find the current config file and go from there.

But remember to go back and enable anything specific for any devices you
don't have plugged in at the moment.

Hope this helps,

greg k-h
