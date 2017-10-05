From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] ARM: dts: gr-peach: Add ETHER pin group
Date: Thu, 5 Oct 2017 15:43:39 +0200
Message-ID: <20171005134339.GJ13247@lunn.ch>
References: <1507193900-23801-1-git-send-email-jacopo+renesas@jmondi.org>
 <1507193900-23801-4-git-send-email-jacopo+renesas@jmondi.org>
 <CAMuHMdWLt9EYp21YiMp7uEGWgjEO_VztbDOyvhr+RxkrAKRYYA@mail.gmail.com>
 <20171005093915.GP4037@w540>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Chris Brandt <Chris.Brandt@renesas.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: jacopo mondi <jacopo@jmondi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:40447 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751280AbdJENnq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 09:43:46 -0400
Content-Disposition: inline
In-Reply-To: <20171005093915.GP4037@w540>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 11:39:15AM +0200, jacopo mondi wrote:
> Hi Geert
> 
> On Thu, Oct 05, 2017 at 11:09:40AM +0200, Geert Uytterhoeven wrote:
> > Hi Jacopo,
> >
> > On Thu, Oct 5, 2017 at 10:58 AM, Jacopo Mondi <jacopo+renesas@jmondi.org> wrote:
> > > Add pin configuration subnode for ETHER pin group and enable the interface.
> > >
> > > Signed-off-by: Jacopo Mondi <jacopo+renesas@jmondi.org>
> >
> > Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
> >
> > > --- a/arch/arm/boot/dts/r7s72100-gr-peach.dts
> > > +++ b/arch/arm/boot/dts/r7s72100-gr-peach.dts
> >
> > > @@ -88,3 +110,19 @@
> > >
> > >         status = "okay";
> > >  };
> > > +
> > > +&ether {
> > > +       pinctrl-names = "default";
> > > +       pinctrl-0 = <&ether_pins>;
> > > +
> > > +       status = "okay";
> > > +
> > > +       reset-gpios = <&port4 2 GPIO_ACTIVE_LOW>;
> > > +       reset-delay-us = <5>;
> >
> > I'm afraid the PHY people (not CCed ;-) will want you to move these reset
> > properties to the phy subnode these days, despite
> > Documentation/devicetree/bindings/net/mdio.txt...

Hi Jocopo

So what is this reset resetting?

The MAC?
The PHY?

    Andrew
