From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v0 01/10] arm: orion5x: Add required properties for
 orion-wdt to DT node
Date: Sat, 16 Jul 2016 18:03:51 +0200
Message-ID: <20160716160351.GB1777@lunn.ch>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-2-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason@lakedaemon.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jamie Lentin <jm@lentin.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468679348-10522-2-git-send-email-jm@lentin.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 16, 2016 at 03:28:59PM +0100, Jamie Lentin wrote:
> orion-wdt refuses to start without these properties defined, so lift
> definitions out of kirkwood/dove.dtsi
> 
> Signed-off-by: Jamie Lentin <jm@lentin.co.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew


> ---
>  arch/arm/boot/dts/orion5x.dtsi | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm/boot/dts/orion5x.dtsi b/arch/arm/boot/dts/orion5x.dtsi
> index e1b6d2a..fbccfbb 100644
> --- a/arch/arm/boot/dts/orion5x.dtsi
> +++ b/arch/arm/boot/dts/orion5x.dtsi
> @@ -144,9 +144,10 @@
>  
>  			wdt: wdt@20300 {
>  				compatible = "marvell,orion-wdt";
> -				reg = <0x20300 0x28>;
> +				reg = <0x20300 0x28>, <0x20108 0x4>;
>  				interrupt-parent = <&bridge_intc>;
>  				interrupts = <3>;
> +				clocks = <&core_clk 0>;
>  				status = "okay";
>  			};
>  
> -- 
> 2.8.1
> 
