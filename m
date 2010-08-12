From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] phylib: available for any speed ethernet
Date: Wed, 11 Aug 2010 23:04:04 -0700 (PDT)
Message-ID: <20100811.230404.112613974.davem@davemloft.net>
References: <20100811162657.cfb767a7.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36713
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485Ab0HLGDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 02:03:46 -0400
In-Reply-To: <20100811162657.cfb767a7.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 11 Aug 2010 16:26:57 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Several gigabit network drivers (SB1250_MAC, TIGON3, FSL, GIANFAR,
> UCC_GETH, MV643XX_ETH, XILINX_LL_TEMAC, S6GMAC, STMMAC_ETH, PASEMI_MAC,
> and OCTEON_ETHERNET) select PHYLIB.  These drivers are not under
> NET_ETHERNET (10/100 mbit), so this warning is generated (long, irrelevant
> parts are omitted):
> 
> warning: (NET_DSA && NET && EXPERIMENTAL && NET_ETHERNET && !S390 || ... || SB1250_MAC && NETDEVICES && NETDEV_1000 && SIBYTE_SB1xxx_SOC || TIGON3 && NETDEVICES && NETDEV_1000 && PCI || FSL_PQ_MDIO && NETDEVICES && NETDEV_1000 && FSL_SOC || GIANFAR && NETDEVICES && NETDEV_1000 && FSL_SOC || UCC_GETH && NETDEVICES && NETDEV_1000 && QUICC_ENGINE || MV643XX_ETH && NETDEVICES && NETDEV_1000 && (MV64X60 || PPC32 || PLAT_ORION) || XILINX_LL_TEMAC && NETDEVICES && NETDEV_1000 && (PPC || MICROBLAZE) || S6GMAC && NETDEVICES && NETDEV_1000 && XTENSA_VARIANT_S6000 || STMMAC_ETH && NETDEV_1000 && NETDEVICES && CPU_SUBTYPE_ST40 || PASEMI_MAC && NETDEVICES && NETDEV_10000 && PPC_PASEMI && PCI || OCTEON_ETHERNET && STAGING && !STAGING_EXCLUDE_BUILD && CPU_CAVIUM_OCTEON) selects PHYLIB which has unmet d
 irect dependencies (!S390 && NET_ETHERNET)
> 
> PHYLIB is used by non-10/100 mbit ethernet drivers, so change the dependencies
> to be NETDEVICES instead of NET_ETHERNET.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Fair enough, applied, thanks Randy.
