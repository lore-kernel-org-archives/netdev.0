From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
Date: Thu, 24 Aug 2017 15:39:22 +0200
Message-ID: <20170824133922.GC8022@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-3-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824083823.16826-3-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static const struct mvebu_comhy_conf mvebu_comphy_modes[] = {
> +	/* lane 0 */
> +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
> +	/* lane 1 */
> +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
> +	/* lane 2 */
> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
> +	/* lane 3 */
> +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
> +	/* lane 4 */
> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
> +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
> +	/* lane 5 */
> +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
> +};

Do other Marvell SoCs re-use this IP? Maybe add cp110 to the name here
to indicate what SoC this configuration belongs to? I guess at some
point, the compatible string will be used to select the correct table
for the hardware variant.

> +static const struct of_device_id mvebu_comphy_of_match_table[] = {
> +	{ .compatible = "marvell,comphy-cp110" },

Is that specific enough? It seems like this table is easy to change in
the VHDL. Could there be another cp110 with a different configuration?

    Andrew
