From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 2/3] dt-binding: net: sfp binding documentation
Date: Fri, 1 Sep 2017 12:12:37 -0500
Message-ID: <20170901171237.ge7dconrtrog2tah@rob-hp-laptop>
References: <d1e64c5752ef0dd5c5b543c2d4c3ef1783318173.1504086672.git.baruch@tkos.co.il>
 <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch@tkos.co.il>
 <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
 <20170830111118.wy62va6sjzsxrgoo@tarshish>
 <c3e8af44-bf58-81d7-bd51-d2538dcd41d9@cogentembedded.com>
 <20170830112557.dhcl3pv7gmuzg22v@tarshish>
 <20170830145829.GA22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170830145829.GA22289-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 04:58:29PM +0200, Andrew Lunn wrote:
> > > > >     Your example shows there's GPIO phandle *and* specifier.
> > > > 
> > > > Would "GPIO specifier" be enough here?
> > > 
> > >    No, specifier is the cells following GPIO (or any other) phandle.
> > 
> > So this should be "GPIO phandle and specifier of ...", is that correct?
> > 
> > I have found very few (< 4) occurrences of this language in (lots of) '-gpios' 
> > property descriptions under Documentation/devicetree/bindings/. Is this a new 
> > requirement?
> 
> Sometimes it is just easier to refer to another document:
> 
> GPIO, as defined in Documentation/devicetree/binding/gpio/gpio.txt

Yes, and what I care about here is how many GPIOs, direction and active 
state. IOW, worry about the information necessary to validate a specific 
instance is correct. And hopefully someday we'll have a format parseable 
to do that checking, and all the free form text will be gone.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
