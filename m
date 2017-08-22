From: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Tue, 22 Aug 2017 07:49:01 +0300
Message-ID: <20170822044900.debakzpc3qatx4cg@sapphire.tkos.co.il>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

On Mon, Aug 21, 2017 at 02:10:33PM -0500, Rob Herring wrote:
> On Sun, Aug 20, 2017 at 5:28 AM, Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org> wrote:
> > Add device-tree binding documentation SFP transceivers. Support for SFP
> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> >
> > Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> > ---
> >
> > The SFP driver is on net-next.
> >
> > Not sure about the rate-select-gpio property name. The SFP+ standard
> > (not supported yet) uses two signals, RS0 and RS1. RS0 is compatible
> > with the SFP rate select signal, while RS1 controls the Tx rate.
> > ---
> >  Documentation/devicetree/bindings/net/sff-sfp.txt | 24 +++++++++++++++++++++++
> >  1 file changed, 24 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/sff-sfp.txt
> >
> > diff --git a/Documentation/devicetree/bindings/net/sff-sfp.txt b/Documentation/devicetree/bindings/net/sff-sfp.txt
> > new file mode 100644
> > index 000000000000..f0c27bc3925e
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sff-sfp.txt
> > @@ -0,0 +1,24 @@
> > +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> > +Transceiver
> > +
> > +Required properties:
> > +
> > +- compatible : must be "sff,sfp"
> 
> Need to document "sff" vendor prefix.

"sff" stands for Small Form Factor Committee, now under Storage Networking 
Industry Association (SNIA). Not really a vendor, but a standards body. Does 
that count? I could not find any other example in vendor-prefixes.txt, other 
than "linux" which is kind of special.

> Kind of a short name, but I guess it is sufficient. Are there
> revisions of the standard (not SFP+) or more than one form factor (I
> don't recall any)?

I'm not aware of any other revisions.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org - tel: +972.2.679.5364, http://www.tkos.co.il -
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
