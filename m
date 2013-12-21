From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/8] b44: add support for external PHY
Date: Fri, 20 Dec 2013 20:49:29 -0500 (EST)
Message-ID: <20131220.204929.1496435862329345815.davem@davemloft.net>
References: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org, f.fainelli@gmail.com
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab3LUBta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 20:49:30 -0500
In-Reply-To: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Fri, 20 Dec 2013 02:16:05 +0100

> This adds support for an external phy connected to the mac controlled 
> by b44. This is used on home routers of the BCM47xx line where this MAC 
> core was used and is contended to an external switch core through MII. 
> These patches are in OpenWrt for some time and are tested by different 
> users with different devices.
> 
> The publicly available Programmer's Reference Guide for some of these 
> chips help making this patch it would be nice to have such a 
> documentation for more Broadcom Chips like some SoCs.
> https://www.broadcom.com/collateral/pg/440X-PG02-R.pdf
> 
> v3:
>  - remove changes to the fixed phy driver
>  - call fixed_phy_add() in arch/mips/bcm47xx/setup.c before the fixed 
>    phy gets registered
> 
> v2: 
>  - add fixed phy driver patch
>  - use fixed phy driver in b44
>  - some smaller changes and typos

Series applied, thanks.
