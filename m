From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v0 05/10] arm: orion5x: Add DT include for mv88f5181
Date: Sat, 16 Jul 2016 18:17:45 +0200
Message-ID: <20160716161745.GF1777@lunn.ch>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-6-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Imre Kaloz <kaloz-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1468679348-10522-6-git-send-email-jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 16, 2016 at 03:29:03PM +0100, Jamie Lentin wrote:

You need to put somewhere here for the commit log.

Otherwise this looks O.K.

	  Andrew

> Signed-off-by: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
> ---
>  .../bindings/arm/marvell/marvell,orion5x.txt       |  1 +
>  arch/arm/boot/dts/orion5x-mv88f5181.dtsi           | 35 ++++++++++++++++++++++
>  2 files changed, 36 insertions(+)
>  create mode 100644 arch/arm/boot/dts/orion5x-mv88f5181.dtsi
> 
> diff --git a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
> index a888011..ff3c120 100644
> --- a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
> +++ b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
> @@ -9,6 +9,7 @@ compatible: must contain "marvell,orion5x"
>  In addition, the above compatible shall be extended with the specific
>  SoC. Currently known SoC compatibles are:
>  
> +"marvell,orion5x-88f5181"
>  "marvell,orion5x-88f5182"
>  
>  And in addition, the compatible shall be extended with the specific
> diff --git a/arch/arm/boot/dts/orion5x-mv88f5181.dtsi b/arch/arm/boot/dts/orion5x-mv88f5181.dtsi
> new file mode 100644
> index 0000000..b51e7ac
> --- /dev/null
> +++ b/arch/arm/boot/dts/orion5x-mv88f5181.dtsi
> @@ -0,0 +1,35 @@
> +/*
> + * Copyright (C) 2016 Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include "orion5x.dtsi"
> +
> +/ {
> +	compatible = "marvell,orion5x-88f5181", "marvell,orion5x";
> +
> +	soc {
> +		compatible = "marvell,orion5x-88f5181-mbus", "simple-bus";
> +
> +		internal-regs {
> +			pinctrl: pinctrl@10000 {
> +				compatible = "marvell,88f5181-pinctrl";
> +				reg = <0x10000 0x8>, <0x10050 0x4>;
> +			};
> +
> +			core_clk: core-clocks@10030 {
> +				compatible = "marvell,mv88f5181-core-clock";
> +				reg = <0x10010 0x4>;
> +				#clock-cells = <1>;
> +			};
> +
> +			mbusc: mbus-controller@20000 {
> +				compatible = "marvell,mbus-controller";
> +				reg = <0x20000 0x100>, <0x1500 0x20>;
> +			};
> +		};
> +	};
> +};
> -- 
> 2.8.1
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
