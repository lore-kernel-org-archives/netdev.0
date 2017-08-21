From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Mon, 21 Aug 2017 18:06:53 +0300
Message-ID: <20170821150653.jmoogmxklkfbrzxg@sapphire.tkos.co.il>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <20170821125317.GS20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:46561 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753206AbdHUPG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 11:06:59 -0400
Content-Disposition: inline
In-Reply-To: <20170821125317.GS20805@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Mon, Aug 21, 2017 at 01:53:17PM +0100, Russell King - ARM Linux wrote:
> On Sun, Aug 20, 2017 at 01:28:06PM +0300, Baruch Siach wrote:
> > Add device-tree binding documentation SFP transceivers. Support for SFP
> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> > 
> > The SFP driver is on net-next.
> > 
> > Not sure about the rate-select-gpio property name. The SFP+ standard
> > (not supported yet) uses two signals, RS0 and RS1. RS0 is compatible
> > with the SFP rate select signal, while RS1 controls the Tx rate.
> 
> SFP+ is usable with this, but the platforms I have do not wire the
> rate select pins on the SFP+ sockets to GPIOs, but hard-wire them.

So maybe naming this signal 'rate-select0-gpio' would make it more future 
(SPF+) proof? Or 'rate-select-rx-gpio'?

> Note that I didn't expect the SFP code to just get merged with very
> little in the way of real in-depth review of things like:
> 
> * the way the SFP code works, and its structure
> * analysis of the bindings checking that they're fit for everyone's
>   purposes.

I was also surprised to see the "sff,sfp" compatible string with no ack from 
DT maintainers. Hence this RFC.

> The implementation that I've designed is based around the boards that
> I have access to and the various public SFP documentation.  I think
> documenting the bindings suggests that they are stable - I don't think
> we're really ready to make that assertion yet - there may be things
> that have been missed which will only come up when other people start
> using this code.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
