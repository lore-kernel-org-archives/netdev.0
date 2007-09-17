From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH 3/3] Blackfin EMAC driver: Add phyabstraction layer
	supporting in bfin_emac driver
Date: Mon, 17 Sep 2007 11:11:44 +0800
Message-ID: <1189998704.7800.1.camel@roc-desktop>
References: <1189911475.9901.8.camel@roc-laptop>
	 <200709162251.01558.rgetz@blackfin.uclinux.org>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, jeff@garzik.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:2609 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbXIQDPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:15:48 -0400
In-Reply-To: <200709162251.01558.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-09-16 at 22:51 -0400, Robin Getz wrote:
> On Sat 15 Sep 2007 22:57, Bryan Wu pondered:
> > 
> >  - add MDIO functions and register mdio bus
> >  - add phy abstraction layer (PAL) functions and use PAL API
> >  - test on STAMP537 board
> 
> Today, the Kconfig for the Blackfin just includes:
> 
> > config BFIN_MAC
> >         tristate "Blackfin 536/537 on-chip mac support"
> >         depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
> >         select CRC32
> >         select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
> >         help
> >           This is the driver for blackfin on-chip mac device. Say Y if you
> > want it compiled into the kernel. This driver is also available as a module
> > ( = code which can be inserted in and removed from the running kernel
> > whenever you want). The module will be called bfin_mac.
> 
> Since you are adding requirement for the PHYLIB with this patch, should there
> be a select for that?
> 
> -Robin

OK, I will send a patch for  this update, since some people failed to
compile the kernel without select the PHYLIB.

Thanks
-Bryan Wu
