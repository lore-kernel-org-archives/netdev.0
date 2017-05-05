From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 00/20] net-next: stmmac: add dwmac-sun8i ethernet
 driver
Date: Fri, 5 May 2017 14:13:54 +0200
Message-ID: <20170505121354.GA14023@Red>
References: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170501124520.3769-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2017 at 02:45:00PM +0200, Corentin Labbe wrote:
> Hello
> 
> This patch series add the driver for dwmac-sun8i which handle the Ethernet MAC
> present on Allwinner H3/H5/A83T/A64 SoCs.
> 
> This driver is the continuation of the sun8i-emac driver.
> During the development, it appeared that in fact the hardware was a modified
> version of some dwmac.
> So the driver is now written as a glue driver for stmmac.
> 
> It supports 10/100/1000 Mbit/s speed with half/full duplex.
> It can use an internal PHY (MII 10/100) or an external PHY
> via RGMII/RMII.
> 
> This patch series enable the driver only for the H3/A64/H5 SoC since A83T
> doesn't have the necessary clocks present in mainline.
> 
> The driver have been tested on the following boards:
> - H3 Orange PI PC, BananaPI-M2+
> - A64 Pine64, BananaPi-M64
> - A83T BananaPI-M3
> 
> The first two patchs are some mandatory changes for letting dwmac-sun8i be used.
> The following three patchs add the driver and its documentation.
> The remaining are DT patch enabling it.
> 
> Regards
> Corentin Labbe
> 

Hello Giuseppe

Since this serie have only one minor comment on documentation, could you give me your view about it ?

Regards
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
