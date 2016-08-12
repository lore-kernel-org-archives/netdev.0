From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v6 0/3] net: phy: Add xilinx gmiitorgmii converter
 support
Date: Fri, 12 Aug 2016 16:57:53 -0700 (PDT)
Message-ID: <20160812.165753.1652467337612232120.davem@davemloft.net>
References: <1470808208-32133-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470808208-32133-1-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Date: Wed, 10 Aug 2016 11:20:05 +0530

> The Gigabit Media Independent Interface (GMII) to Reduced Gigabit Media
> Independent Interface (RGMII) core provides the RGMII between RGMII-compliant
> Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
> This core can be used in all three modes of operation(10/100/1000 Mb/s).
> The Management Data Input/Output (MDIO) interface is used to configure the
> Speed of operation. This core can switch dynamically between the three
> Different speed modes by configuring the conveter register through mdio write.
> 
> The conveter sits b/w the MAC and external phy like below
> 
> MACB <==> GMII2RGMII <==> RGMII_PHY
> 
>         MDIO    <========> GMII2RGMII
> MCAB <=======>
>                 <========> RGMII
> 
> Using MAC MDIO bus we can access both the converter and the external PHY.
> We need to program the line speed of the converter during run time based
> On the external phy negotiated speed.
> 
> This patch series does the below
> ---> Add mask for Control register 10Mbps speed.
> ---> Add support for xilinx gmiitorgmii converter.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
