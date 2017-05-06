From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/5] phy: micrel: add Microchip KSZ 9477 Switch
 PHY support
Date: Sat, 6 May 2017 05:50:21 +0200
Message-ID: <20170506035021.GB14749@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A5BFF6@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51870 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750899AbdEFDuX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 23:50:23 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A5BFF6@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +}, {
> +	.phy_id		= PHY_ID_KSZ9477,
> +	.phy_id_mask	= MICREL_PHY_ID_MASK,
> +	.name		= "Microchip KSZ9477",
> +	.features	= PHY_GBIT_FEATURES,
> +	.flags		= PHY_HAS_MAGICANEG,

Is this magic still used anywhere? I could not find anything.

   Andrew
