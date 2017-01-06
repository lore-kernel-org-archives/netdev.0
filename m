From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 2/2] ARM: dts: dra72-evm-revc: enable irqs for dp83867
 eth phys
Date: Fri, 6 Jan 2017 13:54:52 -0800
Message-ID: <20170106215451.GI2630@atomide.com>
References: <20170106205543.4748-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:55448 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966269AbdAFVy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 16:54:56 -0500
Content-Disposition: inline
In-Reply-To: <20170106205543.4748-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Grygorii Strashko <grygorii.strashko@ti.com> [170106 12:56]:
> TI DRA72-EVM Rev C has two DP83867 ethernet phys which support IRQ
> generation in case of phy/link status changes. The INT/PWDN lines from both
> DP83867 phys are wired to DRA7 gpio6.16, so reflect the same in DT.

Hmm not seeing the patch 1/2 here.. Can this one be queued separately?
Is it for v4.11 or a fix?

Regards,

Tony

> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  arch/arm/boot/dts/dra72-evm-revc.dts | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm/boot/dts/dra72-evm-revc.dts b/arch/arm/boot/dts/dra72-evm-revc.dts
> index c3d939c..3ecac56 100644
> --- a/arch/arm/boot/dts/dra72-evm-revc.dts
> +++ b/arch/arm/boot/dts/dra72-evm-revc.dts
> @@ -68,6 +68,8 @@
>  		ti,tx-internal-delay = <DP83867_RGMIIDCTL_250_PS>;
>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
>  		ti,min-output-impedance;
> +		interrupt-parent = <&gpio6>;
> +		interrupts = <16 IRQ_TYPE_EDGE_FALLING>;
>  	};
>  
>  	dp83867_1: ethernet-phy@3 {
> @@ -75,6 +77,8 @@
>  		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_25_NS>;
>  		ti,tx-internal-delay = <DP83867_RGMIIDCTL_250_PS>;
>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
> -		ti,min-output-imepdance;
> +		ti,min-output-impedance;
> +		interrupt-parent = <&gpio6>;
> +		interrupts = <16 IRQ_TYPE_EDGE_FALLING>;
>  	};
>  };
> -- 
> 2.10.1.dirty
> 
