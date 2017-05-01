From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v5 00/20] net-next: stmmac: add dwmac-sun8i ethernet
 driver
Date: Mon, 1 May 2017 16:45:41 +0200
Message-ID: <20170501144541.GB1285@lunn.ch>
References: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
 <20170501140133.GD31281@lunn.ch>
 <CAGb2v67qGqswdz_JcDaD5jTkcvtBuzqqP8KZh=S_5pkp=o6cUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v67qGqswdz_JcDaD5jTkcvtBuzqqP8KZh=S_5pkp=o6cUQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2017 at 10:28:46PM +0800, Chen-Yu Tsai wrote:
> On Mon, May 1, 2017 at 10:01 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
> > On Mon, May 01, 2017 at 02:45:00PM +0200, Corentin Labbe wrote:
> >> Hello
> >>
> >> This patch series add the driver for dwmac-sun8i which handle the Ethernet MAC
> >> present on Allwinner H3/H5/A83T/A64 SoCs.
> >>
> >> This driver is the continuation of the sun8i-emac driver.
> >> During the development, it appeared that in fact the hardware was a modified
> >> version of some dwmac.
> >> So the driver is now written as a glue driver for stmmac.
> >>
> >> It supports 10/100/1000 Mbit/s speed with half/full duplex.
> >> It can use an internal PHY (MII 10/100) or an external PHY
> >> via RGMII/RMII.
> >
> > Hi Corentin
> >
> > Sorry if this has been asked before....
> >
> > Does the internal PHY have a phy driver? It seems like
> > tx-delay-ps/rx-delay-ps are properties of this internal PHY, and so
> > should be in the phy driver, if it has one.
> 
> Nope. These affect the delay lines for the external PHY interface.

Oh, yes. I understood the patch wrong.

None of the patches actually use these properties. Are they actually
needed? We should avoid adding vendor specific properties, if they are
not used.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
