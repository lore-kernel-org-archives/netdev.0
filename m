From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: mvpp2: use the GoP interrupt for link
 status changes
Date: Thu, 31 Aug 2017 15:47:24 +0200
Message-ID: <20170831134724.GO22289@lunn.ch>
References: <20170831071256.18416-1-antoine.tenart@free-electrons.com>
 <20170831071256.18416-3-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170831071256.18416-3-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 09:12:55AM +0200, Antoine Tenart wrote:
> +static void mvpp22_gop_unmask_irq(struct mvpp2_port *port)
> +{
> +	u32 val;
> +
> +	if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
> +	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
> +	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
> +	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID ||

Hi Antoine

phy_interface_mode_is_rgmii()

	Andrew
