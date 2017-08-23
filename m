From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Wed, 23 Aug 2017 14:57:44 +0100
Message-ID: <20170823135744.GU20805@n2100.armlinux.org.uk>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <20170821125317.GS20805@n2100.armlinux.org.uk>
 <20170821150653.jmoogmxklkfbrzxg@sapphire.tkos.co.il>
 <CAL_JsqJNeibfFVKVjdTJJ88WKonSYnXMdT5mu7V46AGPRbAKbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baruch Siach <baruch@tkos.co.il>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:57552 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754034AbdHWN57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 09:57:59 -0400
Content-Disposition: inline
In-Reply-To: <CAL_JsqJNeibfFVKVjdTJJ88WKonSYnXMdT5mu7V46AGPRbAKbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 02:12:42PM -0500, Rob Herring wrote:
> On Mon, Aug 21, 2017 at 10:06 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> > Hi Russell,
> >
> > On Mon, Aug 21, 2017 at 01:53:17PM +0100, Russell King - ARM Linux wrote:
> >> On Sun, Aug 20, 2017 at 01:28:06PM +0300, Baruch Siach wrote:
> >> > Add device-tree binding documentation SFP transceivers. Support for SFP
> >> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> >> >
> >> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> >> > ---
> >> >
> >> > The SFP driver is on net-next.
> >> >
> >> > Not sure about the rate-select-gpio property name. The SFP+ standard
> >> > (not supported yet) uses two signals, RS0 and RS1. RS0 is compatible
> >> > with the SFP rate select signal, while RS1 controls the Tx rate.
> >>
> >> SFP+ is usable with this, but the platforms I have do not wire the
> >> rate select pins on the SFP+ sockets to GPIOs, but hard-wire them.
> >
> > So maybe naming this signal 'rate-select0-gpio' would make it more future
> > (SPF+) proof? Or 'rate-select-rx-gpio'?
> 
> Just extend it by making it an array of 2 gpios.

What do you do if you have only one rate select wired up and it doesn't
correspond with the first?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
