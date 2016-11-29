From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/2] net: phy: bcm7xxx: Plug in support for
 reading PHY error counters
Date: Tue, 29 Nov 2016 03:50:18 +0100
Message-ID: <20161129025018.GA28968@lunn.ch>
References: <20161129010457.17438-1-f.fainelli@gmail.com>
 <20161129010457.17438-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32807 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754981AbcK2Cu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 21:50:26 -0500
Content-Disposition: inline
In-Reply-To: <20161129010457.17438-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct bcm7xxx_phy_priv {
> +	u64	*stats;
> +};

> +static int bcm7xxx_28nm_probe(struct phy_device *phydev)
> +{
> +	struct bcm7xxx_phy_priv *priv;
> +
> +	priv = devm_kzalloc(&phydev->mdio.dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	phydev->priv = priv;
> +
> +	priv->stats = devm_kzalloc(&phydev->mdio.dev,
> +				   bcm_phy_get_sset_count(phydev), GFP_KERNEL);

Hi Florian

Should there be a * sizeof(u64) in there?

       Andrew
