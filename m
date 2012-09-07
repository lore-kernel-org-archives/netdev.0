From: Timur Tabi <timur@freescale.com>
Subject: Re: linux-next: Tree for Sept 4 (drivers/net/phy/mdio-mux-mmioreg.c)
Date: Fri, 7 Sep 2012 14:37:38 -0500
Message-ID: <504A4D02.8050709@freescale.com>
References: <20120904171330.f6b0a922a754ba0f3acc123b@canb.auug.org.au> <5046933A.6080400@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	<linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.186] ([216.32.181.186]:45917 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755459Ab2IGTjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 15:39:18 -0400
In-Reply-To: <5046933A.6080400@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap wrote:
> drivers/net/phy/mdio-mux-mmioreg.c: In function 'mdio_mux_mmioreg_probe':
> drivers/net/phy/mdio-mux-mmioreg.c:83:2: error: implicit declaration of function 'of_address_to_resource'

I can't reproduce the problem, but I think I have a fix.  I'll post a
patch in a minute.  Can you test it and let me know (e.g. via an ACK)
whether it works?

-- 
Timur Tabi
Linux kernel developer at Freescale
