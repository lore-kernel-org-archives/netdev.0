From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Subject: Re: [PATCH 3/4] arm: mvebu: add Ethernet controllers using mvneta
 driver for Armada 370/XP
Date: Tue, 30 Oct 2012 13:19:15 +0900
Message-ID: <CABMQnVKswTJr9Nd4Etx4Htv0Ckn+pDNqGO8MoPBH-x8y6CwZyA@mail.gmail.com>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1351245804-31478-4-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42964 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab2J3ETr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 00:19:47 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so4143667wgb.1
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 21:19:45 -0700 (PDT)
In-Reply-To: <1351245804-31478-4-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 26, 2012 at 7:03 PM, Thomas Petazzoni
<thomas.petazzoni@free-electrons.com> wrote:
> The Armada 370 SoC has two network units, while the Armada XP has four
> network units. The first two network units are common to both the
> Armada XP and Armada 370, so they are added to armada-370-xp.dtsi,
> while the other two network units are specific to the Armada XP and
> therefore added to armada-xp.dtsi.
>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  arch/arm/boot/dts/armada-370-xp.dtsi |   14 ++++++++++++++
>  arch/arm/boot/dts/armada-xp.dtsi     |   14 ++++++++++++++
>  2 files changed, 28 insertions(+)
>
> diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
> index 16cc82c..d484492 100644
> --- a/arch/arm/boot/dts/armada-370-xp.dtsi
> +++ b/arch/arm/boot/dts/armada-370-xp.dtsi
> @@ -68,6 +68,20 @@
>                         compatible = "marvell,armada-addr-decoding-controller";
>                         reg = <0xd0020000 0x258>;
>                 };
> +
> +                ethernet@d0070000 {
> +                               compatible = "marvell,armada-370-neta";
> +                               reg = <0xd0070000 0x2500>;
> +                               interrupts = <8>;
> +                               status = "disabled";
> +                };
> +
> +                ethernet@d0074000 {
> +                               compatible = "marvell,armada-370-neta";
> +                               reg = <0xd0074000 0x2500>;
> +                               interrupts = <10>;
> +                               status = "disabled";
> +                };

Could you fit an indent?

>         };
>  };
>
> diff --git a/arch/arm/boot/dts/armada-xp.dtsi b/arch/arm/boot/dts/armada-xp.dtsi
> index 71d6b5d..c77a43e 100644
> --- a/arch/arm/boot/dts/armada-xp.dtsi
> +++ b/arch/arm/boot/dts/armada-xp.dtsi
> @@ -51,5 +51,19 @@
>                                 compatible = "marvell,armada-370-xp-system-controller";
>                                 reg = <0xd0018200 0x500>;
>                 };
> +
> +                ethernet@d0030000 {
> +                               compatible = "marvell,armada-370-neta";
> +                               reg = <0xd0030000 0x2500>;
> +                               interrupts = <12>;
> +                               status = "disabled";
> +                };
> +
> +                ethernet@d0034000 {
> +                               compatible = "marvell,armada-370-neta";
> +                               reg = <0xd0034000 0x2500>;
> +                               interrupts = <14>;
> +                               status = "disabled";
> +                };

likewise.

-- 
Nobuhiro Iwamatsu
   iwamatsu at {nigauri.org / debian.org}
   GPG ID: 40AD1FA6
