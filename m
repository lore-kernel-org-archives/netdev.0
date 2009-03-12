From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 15:16:47 -0400
Message-ID: <20090312191647.GE24995@hmsreliant.think-freely.org>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org> <49B95907.4010404@weinigel.se> <20090312190416.GS425@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Christer Weinigel <christer@weinigel.se>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	yanok@emcraft.com, linux-arm-kernel@lists.arm.
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60076 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbZCLTQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:16:56 -0400
Content-Disposition: inline
In-Reply-To: <20090312190416.GS425@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 08:04:16PM +0100, Sascha Hauer wrote:
> On Thu, Mar 12, 2009 at 07:48:39PM +0100, Christer Weinigel wrote:
> > Jamie Lokier wrote:
> >> However there was some attempt to get a reference initrd build into
> >> the kernel.  Did that go anywhere?  It would actually be good to use
> >> that if it exists.
> >
> > That would be a very worthwhile project actually.  Create a package that  
> > uses klibc, does BOOTP/DCHP/NFS and parses the the ip=foo,bar options  
> > the same way the kernel does so that we can finally get rid of the in  
> > kernel stuff.
> 
> Great, but how does this help in setting the MAC address? This would
> just move this exact discussion to the dracut or whatever mailing list,
> but we would still be searching for a generic way to say
> eth0addr=00:01:02:03:04:05 and I bet the arguments stay the same.
> 
You need to do that yourself.  the initramfs is where all your platform specific
bits go.  You're assuming that some tool is automatically going to do this thing
for you that is by definition non-standard.  Non-standard stuff needs manually
process to implement.
Neil

> Sascha
> 
> -- 
> Pengutronix e.K.                           |                             |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
> 
