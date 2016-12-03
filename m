From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Sat, 3 Dec 2016 15:35:53 -0600
Message-ID: <20161203213553.f3agwvaseufglnq6@rob-hp-laptop>
References: <1480326567-6132-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
        galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
        alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
To: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1480326567-6132-1-git-send-email-harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 03:19:27PM +0530, Harini Katakam wrote:
> Add documentations for macb mdio driver.

Bindings document h/w, not drivers.

> 
> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
>  .../devicetree/bindings/net/macb-mdio.txt          | 31 ++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/macb-mdio.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/macb-mdio.txt b/Documentation/devicetree/bindings/net/macb-mdio.txt
> new file mode 100644
> index 0000000..014cedf
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/macb-mdio.txt
> @@ -0,0 +1,31 @@
> +* Cadence MACB MDIO controller
> +
> +Required properties:
> +- compatible: Should be "cdns,macb-mdio"

Only one version ever? This needs more specific compatible strings.

> +- reg: Address and length of the register set of MAC to be used
> +- clock-names: Tuple listing input clock names.
> +	Required elements: 'pclk', 'hclk'
> +	Optional elements: 'tx_clk'
> +- clocks: Phandles to input clocks.
> +
> +Examples:
> +
> +	mdio {
> +		compatible = "cdns,macb-mdio";
> +		reg = <0x0 0xff0b0000 0x0 0x1000>;
> +		clocks = <&clk125>, <&clk125>, <&clk125>;
> +		clock-names = "pclk", "hclk", "tx_clk";
> +		ethernet_phyC: ethernet-phy@C {

lowercase hex for unit addresses please

> +			reg = <0xC>;
> +		};
> +		ethernet_phy7: ethernet-phy@7 {
> +			reg = <0x7>;
> +		};
> +		ethernet_phy3: ethernet-phy@3 {
> +			reg = <0x3>;
> +		};
> +		ethernet_phy8: ethernet-phy@8 {
> +			reg = <0x8>;
> +		};
> +	};
> +
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
