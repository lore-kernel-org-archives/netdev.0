From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:04:16 +0100
Message-ID: <20090312190416.GS425@pengutronix.de>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org> <49B95907.4010404@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58590 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbZCLTEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:04:33 -0400
Content-Disposition: inline
In-Reply-To: <49B95907.4010404@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 07:48:39PM +0100, Christer Weinigel wrote:
> Jamie Lokier wrote:
>> However there was some attempt to get a reference initrd build into
>> the kernel.  Did that go anywhere?  It would actually be good to use
>> that if it exists.
>
> That would be a very worthwhile project actually.  Create a package that  
> uses klibc, does BOOTP/DCHP/NFS and parses the the ip=foo,bar options  
> the same way the kernel does so that we can finally get rid of the in  
> kernel stuff.

Great, but how does this help in setting the MAC address? This would
just move this exact discussion to the dracut or whatever mailing list,
but we would still be searching for a generic way to say
eth0addr=00:01:02:03:04:05 and I bet the arguments stay the same.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
