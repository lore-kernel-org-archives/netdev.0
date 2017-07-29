From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/3] net-next: stmmac: support future possible different
 internal phy mode
Date: Sat, 29 Jul 2017 08:48:15 +0200
Message-ID: <20170729064815.GA2024@Red>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com>
 <20170728135544.GD32230@lunn.ch>
 <20170728142508.GA7221@Red>
 <20170728143600.GB2132@lunn.ch>
 <20170728144424.GB7221@Red>
 <f8fe754c-8b46-a9f6-4020-f7db6c985773@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
        wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        icenowy-h8G6r0blFSE@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f8fe754c-8b46-a9f6-4020-f7db6c985773-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 10:54:30AM -0700, Florian Fainelli wrote:
> On 07/28/2017 07:44 AM, Corentin Labbe wrote:
> > On Fri, Jul 28, 2017 at 04:36:00PM +0200, Andrew Lunn wrote:
> >>>> I've probably asked this before: Does the internal PHY use a different
> >>>> PHY ID in registers 2 and 3?
> >>>>
> >>>
> >>> yes
> >>>
> >>> reg2: 0x0044
> >>> reg3: 0X1500
> > 
> > Copy/paste error, its 1400
> > 
> >>
> >> So this is not about loading the correct PHY driver. You can already
> >> do this based on the PHY IDs...
> >>
> >> This is about selecting which PHY to use. Internal or External?	
> >>
> >>      Andrew
> > 
> > It is too late when we know the PHY ID.
> 
> > We need to set a syscon for choosing external/internal PHY.
> > So we can rely only on DT.
> 
> Since the Device Tree needs to be correct to identify which PHY to use
> (internal or external), if you use the standard compatible string for
> the PHY that contains its OUI, e.g:
> 
> compatible = "ethernet-phy-id0044.1400", "ethernet-phy-ieee802.3-c22"
> 
> then you can have your Ethernet MAC identify whether this is an internal
> PHY by having a list of compatible strings to match against.

So basicly, I replace sun8i-h3-ephy by ethernet-phy-id0044.1400 and it is good ?

> 
> Corentin, can you make sure you copy netdev, Andrew and myself on the
> next submissions so we don't have to keep track of seemingly identical
> threads (this one + the rockchip dwmac changes) and we can work towards
> one solution?

Ok

Thanks
Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
