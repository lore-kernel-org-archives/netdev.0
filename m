From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:16:03 -0400
Message-ID: <20090313001603.GA13764@localhost.localdomain>
References: <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312190517.GD24995@hmsreliant.think-freely.org> <20090312215919.GA19200@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christer Weinigel <christer@weinigel.se>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53082 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbZCMAQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 20:16:34 -0400
Content-Disposition: inline
In-Reply-To: <20090312215919.GA19200@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 09:59:19PM +0000, Jamie Lokier wrote:
> Neil Horman wrote:
> > I've not looked at the figures lately, but how much space does the
> > dhcp client and nfs root code take up in the kernel these days?
> 
> About 4k apparently.  See the difference from "400k compressed?".
> Also, uncompressing that may add 0.5 second boot time on a slow CPU :-)
> 
> > I sympathize with you.  This is exactly what soured me on embedded
> > work a few years back.  Embedded shops are forever compromising
> > doing things correctly in the name of time and schedules, never
> > paying any heed to the possibility that taking extra time to do
> > things in an agreed upon, organized and standard fashion might pay
> > off for them in the long run.
> 
> I must admit that a solution which makes the effective kernel size
> 800k larger (your figure) doesn't look like a good standard to me.
> 
> If that was the "standard", I'd be tempted to add a MAC address driver
> hack to the kernel to save the space :-)
> 
> -- Jamie
> 
I agree that the simple 8k savings is less than stellar, but if you're setting
up a development environment over NFS root, your savings are really unbounded.
Need more space?  Carve out a config option in the kernel that you don't need
immediately, build it as a module, and store it on the NFS root, keeping only
the needed functionality for NFS root in the monolithic image.  Lather, rinse,
repeat until you have enough space.
