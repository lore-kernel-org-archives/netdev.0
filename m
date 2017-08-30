From: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Subject: Re: [PATCH v2 2/3] dt-binding: net: sfp binding documentation
Date: Wed, 30 Aug 2017 14:25:57 +0300
Message-ID: <20170830112557.dhcl3pv7gmuzg22v@tarshish>
References: <d1e64c5752ef0dd5c5b543c2d4c3ef1783318173.1504086672.git.baruch@tkos.co.il>
 <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch@tkos.co.il>
 <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
 <20170830111118.wy62va6sjzsxrgoo@tarshish>
 <c3e8af44-bf58-81d7-bd51-d2538dcd41d9@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c3e8af44-bf58-81d7-bd51-d2538dcd41d9-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Wed, Aug 30, 2017 at 02:15:32PM +0300, Sergei Shtylyov wrote:
> On 8/30/2017 2:11 PM, Baruch Siach wrote:
> 
> > On Wed, Aug 30, 2017 at 02:04:11PM +0300, Sergei Shtylyov wrote:
> > > On 8/30/2017 12:51 PM, Baruch Siach wrote:
> > > 
> > > > Add device-tree binding documentation SFP transceivers. Support for SFP
> > > > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> > > > 
> > > > Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> > > > ---
> > > > v2:
> > > >     Rename -gpio properties to -gpios
> > > >     Rename the rate-select-gpio property to rate-select0-gpios
> > > >     Add the rate-select1-gpios property
> > > >     Add examples
> > > > ---
> > > >    Documentation/devicetree/bindings/net/sff,sfp.txt | 74 +++++++++++++++++++++++
> > > >    1 file changed, 74 insertions(+)
> > > >    create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
> > > > 
> > > > diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > > > new file mode 100644
> > > > index 000000000000..1d9c786d6287
> > > > --- /dev/null
> > > > +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > > > @@ -0,0 +1,74 @@
> > > > +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> > > > +Transceiver
> > > > +
> > > > +Required properties:
> > > > +
> > > > +- compatible : must be "sff,sfp"
> > > > +
> > > > +Optional Properties:
> > > > +
> > > > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > > > +  interface
> > > > +
> > > > +- moddef0-gpios : phandle of the MOD-DEF0 (AKA Mod_ABS) module presence input
> > > > +  gpio signal
> > > 
> > >     Your example shows there's GPIO phandle *and* specifier.
> > 
> > Would "GPIO specifier" be enough here?
> 
>    No, specifier is the cells following GPIO (or any other) phandle.

So this should be "GPIO phandle and specifier of ...", is that correct?

I have found very few (< 4) occurrences of this language in (lots of) '-gpios' 
property descriptions under Documentation/devicetree/bindings/. Is this a new 
requirement?

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org - tel: +972.52.368.4656, http://www.tkos.co.il -
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
