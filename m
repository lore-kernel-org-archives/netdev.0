From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 17:15:06 +0200
Message-ID: <20160714151506.GI6667@lunn.ch>
References: <1468506583-27299-1-git-send-email-p.zabel@pengutronix.de>
 <7346758.UKW3x0KYDY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7346758.UKW3x0KYDY@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 14, 2016 at 04:33:26PM +0200, Arnd Bergmann wrote:
> On Thursday, July 14, 2016 4:29:43 PM CEST Philipp Zabel wrote:
> > +
> > + - micrel,fiber-mode: If present the PHY is configured to operate in fiber mode
> > +
> > +       Some PHYs, such as the KSZ8041FTL variant, support fiber mode, enabled
> > +       by the FXEN boot strapping pin. It can't be determined from the PHY
> > +       registers whether the PHY is in fiber mode, so this boolean device tree
> > +       property can be used to describe it.
> > +
> > +       In fiber mode, auto-negotiation is disabled and the PHY can only work in
> > +       100base-fx (full and half duplex) modes.
> > 
> 
> Could the generic "phy-mode" property used for this, to avoid the need for
> definingn a custom property?

Hi Arnd

phy-mode is about the link between the MAC and the PHY. This property
is about the link between the PHY and its peer PHY.

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
