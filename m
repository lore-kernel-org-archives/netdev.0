From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v7 02/10] arm: dts: sunxi: Restore EMAC changes
Date: Wed, 18 Oct 2017 18:36:53 +0200
Message-ID: <20171018163653.GC15371@lunn.ch>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
 <20171018114458.17891-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, f.fainelli@gmail.com,
 alexandre.torgue@st.com, catalin.marinas@arm.com, linux-sunxi@googlegroups.com,
 will.deacon@arm.com, linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
 wens@csie.org, robh+dt@kernel.org, netdev@vger.kernel.org,
 peppe.cavallaro@st.com, maxime.ripard@free-electrons.com,
 frowand.list@gmail.com, linux-arm-kernel@lists.infradead.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20171018114458.17891-3-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> index e1dba9ffa94b..f2292deaa590 100644
> --- a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> +++ b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> @@ -52,6 +52,7 @@
>  	compatible = "sinovoip,bpi-m2-plus", "allwinner,sun8i-h3";
>  
>  	aliases {
> +		ethernet0 = &emac;
>  		serial0 = &uart0;
>  		serial1 = &uart1;
>  	};
> @@ -111,6 +112,24 @@
>  	status = "okay";
>  };
>  
> +&emac {
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&emac_rgmii_pins>;
> +	phy-supply = <&reg_gmac_3v3>;
> +	phy-handle = <&ext_rgmii_phy>;
> +	phy-mode = "rgmii";
> +
> +	allwinner,leds-active-low;
> +	status = "okay";
> +};
> +
> +&external_mdio {
> +	ext_rgmii_phy: ethernet-phy@1 {
> +		compatible = "ethernet-phy-ieee802.3-c22";
> +		reg = <0>;
> +	};

The reg value should match the @ value.

    Andrew
