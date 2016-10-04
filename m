From: Lokesh Vutla <lokeshvutla-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 3/4] ARM: dts: dra72-evm-revc: fix correct phy delay
 and impedance settings
Date: Tue, 4 Oct 2016 18:41:00 +0530
Message-ID: <a4ef7fc1-73f7-7136-0d60-6ce8a8ff33b9@ti.com>
References: <20161004125607.10569-1-mugunthanvnm@ti.com>
 <20161004125607.10569-4-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161004125607.10569-4-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Tuesday 04 October 2016 06:26 PM, Mugunthan V N wrote:
> The default impedance settings of the phy is not the optimal
> value, due to this the second ethernet is not working. Fix it
> with correct values which makes the second ethernet port to work.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> ---
>  arch/arm/boot/dts/dra72-evm-revc.dts | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/dra72-evm-revc.dts b/arch/arm/boot/dts/dra72-evm-revc.dts
> index f9cfd3b..d626cd7 100644
> --- a/arch/arm/boot/dts/dra72-evm-revc.dts
> +++ b/arch/arm/boot/dts/dra72-evm-revc.dts
> @@ -62,6 +62,7 @@
>  		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_00_NS>;
>  		ti,tx-internal-delay = <DP83867_RGMIIDCTL_1_NS>;
>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
> +		ti,min-output-imepdance;

s/imepdance/impedance

>  	};
>  
>  	dp83867_1: ethernet-phy@3 {
> @@ -69,5 +70,6 @@
>  		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_00_NS>;
>  		ti,tx-internal-delay = <DP83867_RGMIIDCTL_1_NS>;
>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
> +		ti,min-output-imepdance;

same here.

Thanks and regards,
Lokesh

>  	};
>  };
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
