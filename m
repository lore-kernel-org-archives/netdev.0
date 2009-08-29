From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TI DaVinci EMAC: delay DaVinci EMAC initialization
Date: Sat, 29 Aug 2009 00:20:45 -0700 (PDT)
Message-ID: <20090829.002045.43954116.davem@davemloft.net>
References: <1250714395-9588-1-git-send-email-sudhakar.raj@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chaithrika@ti.com, anantgole@ti.com,
	davinci-linux-open-source@linux.davincidsp.com
To: sudhakar.raj@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751446AbZH2HUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:20:31 -0400
In-Reply-To: <1250714395-9588-1-git-send-email-sudhakar.raj@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudhakar Rajashekhara <sudhakar.raj@ti.com>
Date: Wed, 19 Aug 2009 16:39:55 -0400

> On TI's DA850/OMAP-L138 EVM, MAC address is stored in SPI
> flash which is accessed using MTD interface.
> 
> This patch delays the initialization of DaVinci EMAC driver
> by changing module_init to late_initcall. This helps SPI and
> MTD drivers to get initialized before EMAC thereby enabling
> EMAC driver to read the MAC address while booting and use it.
> 
> Tested with NFS on DM644x, DM6467, DA830/OMAP-L137 and
> DA850/OMAP-L138 EVMs.
> 
> Signed-off-by: Sudhakar Rajashekhara <sudhakar.raj@ti.com>
> Reviewed-by: Chaithrika U S <chaithrika@ti.com>

Applied to net-next-2.6, thanks.
