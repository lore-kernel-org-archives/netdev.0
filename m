From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Fri, 13 Mar 2009 02:29:58 +0100
Message-ID: <49B9B716.4060506@weinigel.se>
References: <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312190517.GD24995@hmsreliant.think-freely.org> <20090312215919.GA19200@shareable.org> <49B99DF1.9000509@weinigel.se> <20090313002155.GB13764@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>, davem@davemloft.net,
	shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:43299 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbZCMBaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 21:30:01 -0400
In-Reply-To: <20090313002155.GB13764@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:

> So, I've avoided asking this question, because I didn't want to get off topic,
> but since it appears we're winding up here, I have to ask what your long term
> plan is for your final application.  I can understand being hesitant to invest
> in an initramfs when its solely for your intermediate development (even though I
> think that will pay off for you in the long run), but when your development
> ends, and you ship a product, how do you plan to implement your application?  I
> would imagine you at least need an initramfs to store, load and run your final
> application don't you?  How do you plan on executing it?

Most probably no ramdisk at all, just the mtd driver and flash file 
system driver compiled into the kernel and then "root=/dev/mtdblock4".

For one old product the bootloader programs the mac address into the 
ethernet chip before the kernel boots.  For another embedded system 
thats out in production the bootloader is really dumb and it's up to 
early userspace to extract the mac address from nonvolatile memory and 
do ifconfig hwaddr.

And as I wrote in a different post, most systems I'm working on now 
won't even have ethernet.

   /Christer

