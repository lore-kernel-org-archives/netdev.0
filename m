From: Steve Kieu <haiquy@yahoo.com>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Wed, 31 Aug 2005 07:49:37 +1000 (EST)
Message-ID: <20050830214937.22956.qmail@web53604.mail.yahoo.com>
References: <20050830140516.316e9695@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Daniel Drake <dsd@gentoo.org>, Steve Kieu <haiquy@yahoo.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932485AbVH3Vtq@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050830140516.316e9695@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger <shemminger@osdl.org> wrote:

> You have a version of the Marvell Yukon that was
> affected
> by a fix in 2.6.13.
> 	skge addr 0xfeaf8000 irq 19 chip Yukon-Lite rev 9
> 
> Both the skge and sk98lin driver were fixed to check
> for this.
> Without the fix, the chip will be in the wrong power
> mode.
> 
> The version of sk98lin driver from SysKonnect
> already had the
> fix, so if your distro used that one, it would have
> the reset
> the power mode as needed.

I am afraid not. The last time, I reproduced the
problem using the latest sk98lin driver from
SysKonnect  (run create patch and patch the kernel
2.6.13). Problem still there. The file I got from
sysconnect is:

install-8_23.tar.bz2

> 


S.KIEU


	

	
		
____________________________________________________ 
Do you Yahoo!? 
The New Yahoo! Movies: Check out the Latest Trailers, Premiere Photos and full Actor Database. 
http://au.movies.yahoo.com
