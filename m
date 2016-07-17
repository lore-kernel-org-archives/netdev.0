From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1 0/3] Add Hisilicon MDIO bus driver and FEMAC driver
Date: Sat, 16 Jul 2016 21:44:08 -0700 (PDT)
Message-ID: <20160716.214408.902572525107892568.davem@davemloft.net>
References: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	howell.yang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468571195-59763-1-git-send-email-lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Date: Fri, 15 Jul 2016 16:26:32 +0800

> This patch set adds a Hisilicon MDIO bus driver and
> a Fast Ethernet MAC(FEMAC) driver.
> We also abstract a general interface "of_phy_get_and_connect"
> for PHY connect. User will have no bother with getting
> "phy-mode" and "phy-handle" any more.
> 
> Changes in v1:
> - Pass private data structure instead of struct mii_bus
>   in MDIO read and write operation.
> - Return the error which devm_clk_get() gives when MDIO probe.
> - Leave the clock unprepared and disabled on error when MDIO probe.
> - Abstract a general interface "of_phy_get_and_connect" for PHY connect.
> - Remove the "_reset" suffixes in "reset-names" property.
> - Enable tx per-packet interrupt when tx fifo full.
> - Remove pointless compatible and add SoC specific compatible.
> - Declare only one clock in MAC dts documentation.
> - Add standard unit suffixes for "phy-reset-delays".
> - Use a smaller NAPI poll weight 16 for our Fast Ethernet MAC.
> - Use phy_ethtool_{get|set}_link_ksettings for ethtool ops.
> - Use phydev from struct net_device in MAC driver.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
