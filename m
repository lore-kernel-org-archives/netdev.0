From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v5 11/11] arm64: marvell: dts: add xmdio nodes for 7k/8k
Date: Thu, 15 Jun 2017 18:35:45 +0200
Message-ID: <87y3st5hum.fsf@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
        <20170615144326.24463-12-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38595 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdFOQfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 12:35:47 -0400
In-Reply-To: <20170615144326.24463-12-antoine.tenart@free-electrons.com>
        (Antoine Tenart's message of "Thu, 15 Jun 2017 16:43:26 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Antoine,
 
 On jeu., juin 15 2017, Antoine Tenart <antoine.tenart@free-electrons.com> wrote:

> Add the description of the xMDIO bus for the Marvell Armada 7k and
> Marvell Armada 8k; for both CP110 slave and master. This bus is found
> on Marvell Ethernet controllers and provides an interface with the
> xMDIO bus.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied on mvebu/dt64

Thanks,

Gregory

> ---
>
> @Dave: this patch should go through the mvebu tree as asked by Gregory, thanks!
>
>  arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi | 8 ++++++++
>  arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi  | 8 ++++++++
>  2 files changed, 16 insertions(+)
>
> diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
> index 576e825585c9..8b512b75aea9 100644
> --- a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
> +++ b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
> @@ -97,6 +97,14 @@
>  				clocks = <&cpm_syscon0 1 9>, <&cpm_syscon0 1 5>;
>  			};
>  
> +			cpm_xmdio: mdio@12a600 {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				compatible = "marvell,xmdio";
> +				reg = <0x12a600 0x10>;
> +				status = "disabled";
> +			};
> +
>  			cpm_syscon0: system-controller@440000 {
>  				compatible = "marvell,cp110-system-controller0",
>  					     "syscon";
> diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> index 797208a11f9d..bd0c0e03edd2 100644
> --- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> +++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> @@ -104,6 +104,14 @@
>  				clocks = <&cps_syscon0 1 9>, <&cps_syscon0 1 5>;
>  			};
>  
> +			cps_xmdio: mdio@12a600 {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				compatible = "marvell,xmdio";
> +				reg = <0x12a600 0x10>;
> +				status = "disabled";
> +			};
> +
>  			cps_syscon0: system-controller@440000 {
>  				compatible = "marvell,cp110-system-controller0",
>  					     "syscon";
> -- 
> 2.9.4
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
