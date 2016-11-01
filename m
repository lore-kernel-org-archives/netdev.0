From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v2 3/5] ARM64: dts: meson-gxl: Add ethernet nodes with
 internal PHY
Date: Tue, 1 Nov 2016 12:48:06 +0300
Message-ID: <52cb99f1-93ef-ea53-63c1-a661c2790538@cogentembedded.com>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
 <1477932987-27871-4-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477932987-27871-4-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/31/2016 7:56 PM, Neil Armstrong wrote:

> Add Ethernet node with Internal PHY selection for the Amlogic GXL SoCs
>
> Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
> ---
>  arch/arm64/boot/dts/amlogic/meson-gxl.dtsi | 45 ++++++++++++++++++++++++++++++
>  1 file changed, 45 insertions(+)
>
> diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
> index d1bf381..71670c3 100644
> --- a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
> +++ b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
> @@ -47,6 +47,24 @@
>
>  / {
>  	compatible = "amlogic,meson-gxl";
> +
> +

    No need for these empty lines.

> +};
> +
> +&ethmac {
> +	reg = <0x0 0xc9410000 0x0 0x10000
> +	       0x0 0xc8834540 0x0 0x4>;
> +
> +	clocks = <&clkc CLKID_ETH>,
> +		 <&clkc CLKID_FCLK_DIV2>,
> +		 <&clkc CLKID_MPLL2>;
> +	clock-names = "stmmaceth", "clkin0", "clkin1";
> +
> +	mdio0: mdio0 {

    Should be "mdio0: mdio {" in oprder to comply woth the DT spec.

> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		compatible = "snps,dwmac-mdio";
> +	};
>  };
>
>  &aobus {
[...]

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
