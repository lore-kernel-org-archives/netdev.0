From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Fri, 13 Mar 2009 06:30:13 -0400
Message-ID: <20090313103013.GA27905@hmsreliant.think-freely.org>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312190517.GD24995@hmsreliant.think-freely.org> <20090312215919.GA19200@shareable.org> <49B99DF1.9000509@weinigel.se> <20090313002155.GB13764@localhost.localdomain> <49B9B716.4060506@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, davem@davemloft.net,
	shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38703 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280AbZCMKar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 06:30:47 -0400
Content-Disposition: inline
In-Reply-To: <49B9B716.4060506@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 02:29:58AM +0100, Christer Weinigel wrote:
> Neil Horman wrote:
>
>> So, I've avoided asking this question, because I didn't want to get off topic,
>> but since it appears we're winding up here, I have to ask what your long term
>> plan is for your final application.  I can understand being hesitant to invest
>> in an initramfs when its solely for your intermediate development (even though I
>> think that will pay off for you in the long run), but when your development
>> ends, and you ship a product, how do you plan to implement your application?  I
>> would imagine you at least need an initramfs to store, load and run your final
>> application don't you?  How do you plan on executing it?
>
> Most probably no ramdisk at all, just the mtd driver and flash file  
> system driver compiled into the kernel and then "root=/dev/mtdblock4".
>
Ok, thanks, so you have a place to store user space images.  This thread got me
wondering what you were going to do long term about user space.  I was starting
to think as a space saving measure, that you were building your app into the
kernel or something.

FWIW, I think Uboot has a pretty robust mtd infrastructure that would allow you
to store a initramfs image there for use if you were interested in exploring
that route.

Neil

