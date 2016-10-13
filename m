From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 03/10] ARM: sun8i: dt: Add DT bindings documentation
 for Allwinner sun8i-emac
Date: Thu, 13 Oct 2016 15:39:13 +0200
Message-ID: <20161013133913.GA23079@Red>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-4-git-send-email-clabbe.montjoie@gmail.com>
 <20161010151335.GA3111@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
        wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161010151335.GA3111@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 10:13:35AM -0500, Rob Herring wrote:
> On Fri, Oct 07, 2016 at 10:25:50AM +0200, Corentin Labbe wrote:
> > This patch adds documentation for Device-Tree bindings for the
> > Allwinner sun8i-emac driver.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  .../bindings/net/allwinner,sun8i-emac.txt          | 70 ++++++++++++++++++++++
> >  1 file changed, 70 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> > new file mode 100644
> > index 0000000..92e4ef3b
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> > @@ -0,0 +1,70 @@
> > +* Allwinner sun8i EMAC ethernet controller
> > +
> > +Required properties:
> > +- compatible: should be one of the following string:
> > +		"allwinner,sun8i-a83t-emac"
> > +		"allwinner,sun8i-h3-emac"
> > +		"allwinner,sun50i-a64-emac"
> > +- reg: address and length of the register for the device.
> > +- syscon: A phandle to the syscon of the SoC
> > +- interrupts: interrupt for the device
> > +- clocks: A phandle to the reference clock for this device
> > +- clock-names: should be "ahb"
> > +- resets: A phandle to the reset control for this device
> > +- reset-names: should be "ahb"
> > +- phy-mode: See ethernet.txt
> > +- phy-handle: See ethernet.txt
> > +- #address-cells: shall be 1
> > +- #size-cells: shall be 0
> > +
> > +Optional properties:
> > +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07. Default is 0)
> > +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F. Default is 0)
> > +Both delay properties does not have units, there are arbitrary value.
> 
> They have to have some sort of units. Some number of clocks perhaps. Or 
> just say what register field they correspond to.
> 

I have re-read all 3 datasheets (A64/H3/A83T) and made string search for finding any information.
But still found nothing, no unit, no more informations than I already wrote in this file.

For the register field, just saying that it is used in the syscon register EMAC_CLK_REG is sufficient ?

> > +The TX/RX clock delay chain settings are board specific and could be found
> > +in vendor FEX files.
> > +

Regards

Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
