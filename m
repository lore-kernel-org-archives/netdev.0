From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v2 2/3] dt-binding: net: sfp binding documentation
Date: Wed, 30 Aug 2017 14:11:18 +0300
Message-ID: <20170830111118.wy62va6sjzsxrgoo@tarshish>
References: <d1e64c5752ef0dd5c5b543c2d4c3ef1783318173.1504086672.git.baruch@tkos.co.il>
 <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch@tkos.co.il>
 <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:47052 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751263AbdH3LLV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 07:11:21 -0400
Content-Disposition: inline
In-Reply-To: <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Thanks for reviewing.

On Wed, Aug 30, 2017 at 02:04:11PM +0300, Sergei Shtylyov wrote:
> On 8/30/2017 12:51 PM, Baruch Siach wrote:
> 
> > Add device-tree binding documentation SFP transceivers. Support for SFP
> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> > v2:
> >    Rename -gpio properties to -gpios
> >    Rename the rate-select-gpio property to rate-select0-gpios
> >    Add the rate-select1-gpios property
> >    Add examples
> > ---
> >   Documentation/devicetree/bindings/net/sff,sfp.txt | 74 +++++++++++++++++++++++
> >   1 file changed, 74 insertions(+)
> >   create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > new file mode 100644
> > index 000000000000..1d9c786d6287
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > @@ -0,0 +1,74 @@
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
> > +- moddef0-gpios : phandle of the MOD-DEF0 (AKA Mod_ABS) module presence input
> > +  gpio signal
> 
>    Your example shows there's GPIO phandle *and* specifier.

Would "GPIO specifier" be enough here?

[...]

> > +Example #2: Serdes to PHY to SFP connection
> > +
> > +sfp_eth0: sfp-eth0 {
> > +	compatible = "sff,sfp+";
> > +	i2c-bus = <&sfpp0_i2c>;
> > +	los-gpio = <&cps_gpio1 28 GPIO_ACTIVE_HIGH>;
> 
>    You describe "los-gpios" above , not "los-gpio" (which is a deprecated form).

Will fix.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
