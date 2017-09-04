From: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Subject: Re: [PATCH v3 2/3] dt-binding: net: sfp binding documentation
Date: Tue, 5 Sep 2017 00:11:21 +0300
Message-ID: <20170904211121.hl2gnwxiizli5brd@tarshish>
References: <c2a27566a8eb358ee2566a213c385d0bf3d64307.1504441874.git.baruch@tkos.co.il>
 <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
 <5df7f2f5-04f7-85b1-4a53-935360001b7c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5df7f2f5-04f7-85b1-4a53-935360001b7c-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Mon, Sep 04, 2017 at 01:16:26PM -0700, Florian Fainelli wrote:
> Le 09/03/17 à 05:31, Baruch Siach a écrit : 

[...]

> > diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > new file mode 100644
> > index 000000000000..b98ee5945265
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > @@ -0,0 +1,78 @@
> > +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> > +Transceiver
> > +
> > +Required properties:
> > +
> > +- compatible : must be "sff,sfp"
> > +
> > +Optional Properties:
> > +
> > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > +  interface
> > +
> > +- moddef0-gpios : GPIO phandle and a single specifier of the MOD-DEF0 (AKA
> > +  Mod_ABS) module presence input gpio signal, active (module absent) high
> 
> Sorry for nitpicking on this, why are not we naming this mod-def0-gpios
> which would be consistent with how other GPIOs are named?

I'm fine with that as well. It only requires changing the implementation to 
match.

> > +
> > +- los-gpios : GPIO phandle and a single specifier of the Receiver Loss of
> > +  Signal Indication input gpio signal, active (signal lost) high
> > +
> > +- tx-fault-gpios : GPIO phandle and a single specifier of the Module
> > +  Transmitter Fault input gpio signal, active (fault condition) high
> > +
> > +- tx-disable-gpios : GPIO phandle and a single specifier of the Transmitter
> > +  Disable output gpio signal, active (Tx disable) high
> > +
> > +- rate-select0-gpios : GPIO phandle and a single specifier of the Rx Signaling
> > +  Rate Select (AKA RS0) output gpio signal, low: low Rx rate, high: high Rx
> > +  rate
> > +
> > +- rate-select1-gpios : GPIO phandle and a single specifier of the Tx Signaling
> > +  Rate Select (AKA RS1) output gpio signal (SFP+ only), low: low Tx rate,
> > +  high: high Tx rate

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org - tel: +972.52.368.4656, http://www.tkos.co.il -
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
