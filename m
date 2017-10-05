From: jacopo mondi <jacopo@jmondi.org>
Subject: Re: [PATCH 3/3] ARM: dts: gr-peach: Add ETHER pin group
Date: Thu, 5 Oct 2017 11:39:15 +0200
Message-ID: <20171005093915.GP4037@w540>
References: <1507193900-23801-1-git-send-email-jacopo+renesas@jmondi.org>
 <1507193900-23801-4-git-send-email-jacopo+renesas@jmondi.org>
 <CAMuHMdWLt9EYp21YiMp7uEGWgjEO_VztbDOyvhr+RxkrAKRYYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chris Brandt <Chris.Brandt@renesas.com>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54971 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751278AbdJEJjU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 05:39:20 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdWLt9EYp21YiMp7uEGWgjEO_VztbDOyvhr+RxkrAKRYYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert

On Thu, Oct 05, 2017 at 11:09:40AM +0200, Geert Uytterhoeven wrote:
> Hi Jacopo,
>
> On Thu, Oct 5, 2017 at 10:58 AM, Jacopo Mondi <jacopo+renesas@jmondi.org> wrote:
> > Add pin configuration subnode for ETHER pin group and enable the interface.
> >
> > Signed-off-by: Jacopo Mondi <jacopo+renesas@jmondi.org>
>
> Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
>
> > --- a/arch/arm/boot/dts/r7s72100-gr-peach.dts
> > +++ b/arch/arm/boot/dts/r7s72100-gr-peach.dts
>
> > @@ -88,3 +110,19 @@
> >
> >         status = "okay";
> >  };
> > +
> > +&ether {
> > +       pinctrl-names = "default";
> > +       pinctrl-0 = <&ether_pins>;
> > +
> > +       status = "okay";
> > +
> > +       reset-gpios = <&port4 2 GPIO_ACTIVE_LOW>;
> > +       reset-delay-us = <5>;
>
> I'm afraid the PHY people (not CCed ;-) will want you to move these reset
> properties to the phy subnode these days, despite
> Documentation/devicetree/bindings/net/mdio.txt...

Extending to:
    +andrew@lunn.ch
    +f.fainelli@gmail.com
    +netdev@vger.kernel.org

To hear from them when and how they like to move those properties and
if we can apply this in this shape or not.

Otherwise, if you think it's the case, I can move them nonetheless.

Thanks
   j
>
> > +
> > +       renesas,no-ether-link;
> > +       phy-handle = <&phy0>;
> > +       phy0: ethernet-phy@0 {
> > +               reg = <0>;
> > +       };
> > +};
>
> Gr{oetje,eeting}s,
>
>                         Geert
>
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
>
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
