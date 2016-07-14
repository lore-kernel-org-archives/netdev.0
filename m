From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 17:13:05 +0200
Message-ID: <20160714151305.GH6667@lunn.ch>
References: <1468491528-17515-1-git-send-email-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1468491528-17515-1-git-send-email-p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +static int ksz8041_config_init(struct phy_device *phydev)
> +{
> +	/* Limit supported and advertised modes in fiber mode */
> +	if (of_property_read_bool(phydev->mdio.dev.of_node, "fxen")) {
> +		phydev->dev_flags |= MICREL_PHY_FXEN;
> +		phydev->supported &= SUPPORTED_FIBRE |
> +				     SUPPORTED_100baseT_Full |
> +				     SUPPORTED_100baseT_Half;
> +		phydev->advertising &= ADVERTISED_FIBRE |
> +				       ADVERTISED_100baseT_Full |
> +				       ADVERTISED_100baseT_Half;

Hi Philipp

Does the PHY actually advertise anything? Should phydev->advertising
be set to 0?

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
