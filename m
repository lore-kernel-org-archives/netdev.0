From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:14:21 +0100
Message-ID: <20090312191421.GT425@pengutronix.de>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312190517.GD24995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christer Weinigel <christer@weinigel.se>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	yanok@emcraft.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, wd@denx.de, dzu@denx.de
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48132 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbZCLTOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:14:33 -0400
Content-Disposition: inline
In-Reply-To: <20090312190517.GD24995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 03:05:17PM -0400, Neil Horman wrote:
> On Thu, Mar 12, 2009 at 07:25:10PM +0100, Christer Weinigel wrote:
> > Neil Horman wrote:
> >> You don't need klibc, you can use regular glibc, and even build statically if
> >> you like.  You'll have to use dig or host to do name lookups, but thats also
> >> pretty easy to do.  This really is easier than you think it is :)
> >
> > Size, size, size.  The killer in the embedded world which rules out  
> > glibc.  And have you tried to link glibc statically with something that  
> > uses gethostbyname lately?  It is no longer possible since the  
> > introduction of all the introduction of the dynamic name lookup crap  
> > (ok, it's not really crap, I just feel like it's crap every time I try  
> > to link a networking application statically).  But that's a bit off  
> > topic since I don't need name lookups just to mount a NFS file system.  
> > uclibc also seems to have issues with networking and statically linked  
> > binaries, but I just haven't had time to figure out why yet.
> >
> 
> You didn't read what I wrote very closely, I specifically said you have to dig
> or host to do name lookups, specifically because of the issues with getXbyY.
> When I said I built busybox in 800k (400k compressed), That was with glibc
> statically linked.  End of story.  You're making up problems here, its not that
> big a deal.  I've not looked at the figures lately, but how much space does the
> dhcp client and nfs root code take up in the kernel these days?
 
just checked: disabling CONFIG_IP_PNP and CONFIG_IP_PNP_DHCP saves me
4456 bytes of zImage size on an ARM/PXA build

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
