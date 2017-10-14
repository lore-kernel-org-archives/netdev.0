From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] ARM: dts: gr-peach: Add ETHER pin group
Date: Sat, 14 Oct 2017 17:13:32 +0200
Message-ID: <20171014151332.GD12454@lunn.ch>
References: <1507193900-23801-1-git-send-email-jacopo+renesas@jmondi.org>
 <1507193900-23801-4-git-send-email-jacopo+renesas@jmondi.org>
 <CAMuHMdWLt9EYp21YiMp7uEGWgjEO_VztbDOyvhr+RxkrAKRYYA@mail.gmail.com>
 <20171005093915.GP4037@w540>
 <20171005134339.GJ13247@lunn.ch>
 <20171005154239.GB19008@w540>
 <20171005164826.GL13247@lunn.ch>
 <20171006122445.GA30375@w540>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Chris Brandt <Chris.Brandt@renesas.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: jacopo mondi <jacopo@jmondi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:45303 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753818AbdJNPNi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Oct 2017 11:13:38 -0400
Content-Disposition: inline
In-Reply-To: <20171006122445.GA30375@w540>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > So your binding whats to look something like
> >
> >         ether: ethernet@e8203000 {
> >                 compatible = "renesas,ether-r7s72100";
> >                 reg = <0xe8203000 0x800>,
> >                       <0xe8204800 0x200>;
> >                 interrupts = <GIC_SPI 327 IRQ_TYPE_LEVEL_HIGH>;
> >                 clocks = <&mstp7_clks R7S72100_CLK_ETHER>;
> >                 power-domains = <&cpg_clocks>;
> >                 phy-mode = "mii";
> > 		          phy-handle = <&phy0>;
> >                 #address-cells = <1>;
> >                 #size-cells = <0>;
> >
> >                 mdio: bus-bus {
> >                       #address-cells = <1>;
> >                       #size-cells = <0>;
> >
> >                       phy0: ethernet-phy@1 {
> >                             reg = <1>;
> 
> Why reg = <1> ?
> Shouldn't this be 0, or even better with no reg property at all?

This is the address of the PHY on the MDIO bus. There can be up to 32
devices on the bus. I have no idea what address your PHY is using, so
i just picked a value. 0 can be special, so i avoided it.

	Andrew
