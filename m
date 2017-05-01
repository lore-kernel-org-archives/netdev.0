From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v5 03/20] dt-bindings: net: Add DT bindings documentation
 for Allwinner dwmac-sun8i
Date: Mon, 1 May 2017 15:45:58 +0200
Message-ID: <20170501134558.GC31281@lunn.ch>
References: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
 <20170501124520.3769-4-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170501124520.3769-4-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2017 at 02:45:03PM +0200, Corentin Labbe wrote:
> +emac: ethernet@1c0b000 {
> +	compatible = "allwinner,sun8i-h3-emac";
> +	syscon = <&syscon>;
> +	reg = <0x01c0b000 0x104>;
> +	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> +	interrupt-names = "macirq";
> +	resets = <&ccu RST_BUS_EMAC>;
> +	reset-names = "stmmaceth";
> +	clocks = <&ccu CLK_BUS_EMAC>;
> +	clock-names = "stmmaceth";
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	phy = <&int_mii_phy>;

Hi Corentin

Should this be phy-handle?

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
