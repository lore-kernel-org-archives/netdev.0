From: Greg KH <greg@kroah.com>
Subject: Re: [stable] PROBLEM: SIS900 Driver change in Linux Kernel 2.6.21
	causes kernel panic.
Date: Wed, 16 May 2007 16:12:32 -0700
Message-ID: <20070516231232.GA9047@kroah.com>
References: <577536.90963.qm@web84207.mail.re3.yahoo.com> <20070516221704.GC16810@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: - <kd6lvw@yahoo.com>, Neil Horman <nhorman@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Daniele Venzano <venza@brownhat.org>,
	Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46472 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023AbXEPXOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 19:14:33 -0400
Content-Disposition: inline
In-Reply-To: <20070516221704.GC16810@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 06:17:04PM -0400, Dave Jones wrote:
> On Wed, May 16, 2007 at 02:33:18PM -0700, - wrote:
>  > Kernel version 2.6.20.4 works.  What I'm experiencing is a kernel panic as
>  > soon as the first received packet comes in via the sis900 ethernet
>  > interface.  The machine is locked up and part of the kernel panic message
>  > is lost as it has scrolled off the screen and the virtual terminal has
>  > crashed as well (the kernel appears to have done a permanent halt - the
>  > keyboard LEDs are flashing).  The only way I could get the machine to boot
>  > without this problem was to unplug the ethernet cable - but it would
>  > appear as soon as the the first packet was received after plugging the
>  > cable back in.  That's not good since the machine in question is a server
>  > in a co-location facility (I can't print the screen either).  The kernel
>  > panic was repeatable without fail.  As this usually happens before "init"
>  > is called, the only "program" running is the kernel itself.  I don't have
>  > any syslog/dmesg message recorded to disk for the event.  I've rolled back
>  > to version 2.6.20.4 in the meantime.
> 
> You need this..
> 
> http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git;a=commitdiff_plain;h=dc5a144991ba803bc8afded105c9db1dea0e57ab
> 
> Which is queued for -stable afaik, but no sign of 2.6.21.2 yet. Greg/Chris?

I have a large queue backing up, will try to flush it out by tomorrow
and get a review cycle started.

thanks,

greg "i'm starting to hate travelling" k-h
