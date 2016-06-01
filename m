From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/7] mdio:mux: Enhanced MDIO mux framework for
 integrated multiplexers
Date: Wed, 1 Jun 2016 15:02:07 +0200
Message-ID: <20160601130207.GE31982@lunn.ch>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-2-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464701801-17243-2-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 8453f08..cf40e7a 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -225,6 +225,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  	if (rc)
>  		return rc;
>  
> +	if (of_property_read_bool(np, "mdio-integrated-mux"))
> +		return 0;
> +

Hi

Rather than doing this, did you try setting bus->phy_mask = 0 and
calling mdiobus_register(), rather than of_mdiobus_regsiter() for the
parent bus?

	Andrew
