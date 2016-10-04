From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 4/4] ARM: dts: dra72-evm-revc: fix correct phy delay
Date: Tue, 4 Oct 2016 15:14:56 +0200
Message-ID: <20161004131456.GN11677@lunn.ch>
References: <20161004125607.10569-1-mugunthanvnm@ti.com>
 <20161004125607.10569-5-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161004125607.10569-5-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 04, 2016 at 06:26:07PM +0530, Mugunthan V N wrote:
> The current delay settings of the phy are not the optimal value,
> fix it with correct values.

This should be a separate patch, since it has nothing to do with impedance.

     Andrew

> 
> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> ---
>  arch/arm/boot/dts/dra72-evm-revc.dts | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/dra72-evm-revc.dts b/arch/arm/boot/dts/dra72-evm-revc.dts
> index d626cd7..8472a8c 100644
> --- a/arch/arm/boot/dts/dra72-evm-revc.dts
> +++ b/arch/arm/boot/dts/dra72-evm-revc.dts
> @@ -59,16 +59,16 @@
>  &davinci_mdio {
>  	dp83867_0: ethernet-phy@2 {
>  		reg = <2>;
> -		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_00_NS>;
> -		ti,tx-internal-delay = <DP83867_RGMIIDCTL_1_NS>;
> +		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_25_NS>;
> +		ti,tx-internal-delay = <DP83867_RGMIIDCTL_250_PS>;
>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
>  		ti,min-output-imepdance;
>  	};
>  
>  	dp83867_1: ethernet-phy@3 {
>  		reg = <3>;
> -		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_00_NS>;
> -		ti,tx-internal-delay = <DP83867_RGMIIDCTL_1_NS>;
> +		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_25_NS>;
> +		ti,tx-internal-delay = <DP83867_RGMIIDCTL_250_PS>;
>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
>  		ti,min-output-imepdance;
>  	};
> -- 
> 2.10.0.372.g6fe1b14
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
