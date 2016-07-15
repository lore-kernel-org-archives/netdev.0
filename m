From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v1 0/3] Add Hisilicon MDIO bus driver and FEMAC driver
Date: Fri, 15 Jul 2016 10:41:07 +0200
Message-ID: <20917223.X0KrqBAbxT@wuerfel>
References: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
	frowand.list@gmail.com, davem@davemloft.net, andrew@lunn.ch,
	xuejiancheng@hisilicon.com, benjamin.chenhao@hisilicon.com,
	howell.yang@hisilicon.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, July 15, 2016 4:26:32 PM CEST Dongpo Li wrote:
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
> 

Looks all good to me now,

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

One comment on the submission format: we normally count the initial
submission as "v1", so after [PATCH 0/3], the following version is
[PATCH v2 0/3], not [PATCH v1 0/3].

No need to re-send for this now, and if you end up having to make
other changes, just continue with "v2" for this driver, just follow
the normal scheme if you send another driver.

	Arnd
