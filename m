From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: stmmac: Use the right logging function in
 stmmac_mdio_register
Date: Wed, 9 Aug 2017 16:56:51 +0200
Message-ID: <20170809145651.GK30723@lunn.ch>
References: <20170809144019.17975-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170809144019.17975-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2017 at 04:40:19PM +0200, Romain Perier wrote:
> @@ -285,14 +286,14 @@ int stmmac_mdio_register(struct net_device *ndev)
>  			irq_str = irq_num;
>  			break;
>  		}
> -		netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
> +		dev_info(dev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
>  			    phydev->phy_id, addr, irq_str, phydev_name(phydev),
>  			    act ? " active" : "");

Hi Romain

phy_attached_print() would be better.

     Andrew
