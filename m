From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc75xx: fix MDIO access
Date: Sat, 28 Apr 2012 21:55:36 -0400 (EDT)
Message-ID: <20120428.215536.1073848205954371267.davem@davemloft.net>
References: <20120426195517.GU5277@charybde.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: fillods@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016Ab2D2Bzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 21:55:48 -0400
In-Reply-To: <20120426195517.GU5277@charybde.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Fillod <fillods@users.sf.net>
Date: Thu, 26 Apr 2012 21:55:17 +0200

> * make MDIO read/write to work, the MII_ACCESS_BUSY bit was missing
>   to actually trigger the I/O. Rem: the smsc75xx is different from
>   the smsc95xx in that regard.
> * fix PHY interrupt acknowledge, which needs a mdio_write
>   to clear PHY_INT_SRC instead of a usual read like in smsc95xx.
> * fix bug in phy_init loop that was ignoring BMCR reset bit,
>   akin to smsc95xx's d946092000698fd204d82a9d239103c656fb63bf
> * mark link down on startup and let PHY interrupt deal with carrier
>   changes, akin to 07d69d4238418746a7b85c5d05ec17c658a2a390
> * declare the smsc75xx's MII as GMII capable
> 
> Tested on ARM/Omap3 with LAN7500-CEB.
> 
> Signed-off-by: Stephane Fillod <fillods@users.sf.net>
> Cc: Steve Glendinning <steve.glendinning@shawell.net>

Steve, could you give this a quick review?

Thanks.
