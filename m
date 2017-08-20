From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Sun, 20 Aug 2017 08:57:57 +0200
Message-ID: <20170820065757.GA6081@Red>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
 <20170819203836.GA21567@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170819203836.GA21567-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2017 at 10:38:36PM +0200, Andrew Lunn wrote:
> On Sat, Aug 19, 2017 at 08:50:25PM +0200, Corentin Labbe wrote:
> > On Sat, Aug 19, 2017 at 01:05:21AM +0800, Chen-Yu Tsai wrote:
> > > On Fri, Aug 18, 2017 at 8:21 PM, Corentin Labbe
> > > <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > > In case of a MDIO switch, the registered MDIO node should be
> > > > the parent of the PHY. Otherwise of_phy_connect will fail.
> 
> Hi Corentin
> 
> Sorry, I missed this patch series. Looking at patchwork...

That's my fault, I forgot to set you in recipient like in last send.

> 
> Can you represent the MDIO mux using 
> 
> Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
> 
> It would be better if you could reuse existing infrastructure than
> invent something new.
> 

I think we cannot use mdio-mux-mmioreg since the register for doing the switch is in middle of the "System Control" and shared with other functions.
This is why we use a sycon/regmap for selecting the MDIO.

Regards
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
