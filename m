From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/2] net: phy: realtek: fix RTL8211F TX-delay handling
Date: Mon, 28 Nov 2016 12:07:13 -0500 (EST)
Message-ID: <20161128.120713.220612302416318577.davem@davemloft.net>
References: <20161125131201.19994-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
To: martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161125131201.19994-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date: Fri, 25 Nov 2016 14:11:59 +0100

> The RTL8211F PHY driver currently enables the TX-delay only when the
> phy-mode is PHY_INTERFACE_MODE_RGMII. This is incorrect, because there
> are three RGMII variations of the phy-mode which explicitly request the
> PHY to enable the RX and/or TX delay, while PHY_INTERFACE_MODE_RGMII
> specifies that the PHY should disable the RX and/or TX delays.
> 
> Additionally to the RTL8211F PHY driver change this contains a small
> update to the phy-mode documentation to clarify the purpose of the
> RGMII phy-modes.
> While this may not be perfect yet it's at least a start. Please feel
> free to drop this patch from this series and send an improved version
> yourself.
> 
> These patches are the results of recent discussions, see [0]
> 
> [0] http://lists.infradead.org/pipermail/linux-amlogic/2016-November/001688.html

Series applied, thanks Martin.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
