From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 3/4] arm: mvebu: add Ethernet controllers using mvneta
 driver for Armada 370/XP
Date: Tue, 30 Oct 2012 09:36:29 +0100
Message-ID: <20121030093629.398ce706@skate>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1351245804-31478-4-git-send-email-thomas.petazzoni@free-electrons.com>
	<CABMQnVKswTJr9Nd4Etx4Htv0Ckn+pDNqGO8MoPBH-x8y6CwZyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:49524 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329Ab2J3Igo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 04:36:44 -0400
In-Reply-To: <CABMQnVKswTJr9Nd4Etx4Htv0Ckn+pDNqGO8MoPBH-x8y6CwZyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, 30 Oct 2012 13:19:15 +0900, Nobuhiro Iwamatsu wrote:

> > diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
> > index 16cc82c..d484492 100644
> > --- a/arch/arm/boot/dts/armada-370-xp.dtsi
> > +++ b/arch/arm/boot/dts/armada-370-xp.dtsi
> > @@ -68,6 +68,20 @@
> >                         compatible = "marvell,armada-addr-decoding-controller";
> >                         reg = <0xd0020000 0x258>;
> >                 };
> > +
> > +                ethernet@d0070000 {
> > +                               compatible = "marvell,armada-370-neta";
> > +                               reg = <0xd0070000 0x2500>;
> > +                               interrupts = <8>;
> > +                               status = "disabled";
> > +                };
> > +
> > +                ethernet@d0074000 {
> > +                               compatible = "marvell,armada-370-neta";
> > +                               reg = <0xd0074000 0x2500>;
> > +                               interrupts = <10>;
> > +                               status = "disabled";
> > +                };
> 
> Could you fit an indent?

Right, thanks, will fix.

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
