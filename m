From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
Date: Sun, 9 Jul 2017 20:20:24 -0500
Message-ID: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
 <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Chris Paterson <chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499259711-56175-2-git-send-email-biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 05, 2017 at 02:01:50PM +0100, Biju Das wrote:
> Add support for Gigabit Ethernet E-MAC on r8a7743 (RZ/G1M) SoC.
> Renesas RZ/G1M (R8A7743) SoC Ethernet AVB IP is identical to the R-Car Gen2
> family.

For the subject: "dt-bindings: net: ..."

> 
> Signed-off-by: Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
> Reviewed-by: Chris Paterson <chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/renesas,ravb.txt | 3 ++-
>  drivers/net/ethernet/renesas/ravb_main.c               | 1 +
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index b519503..bc692ab 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -4,7 +4,8 @@ This file provides information on what the device node for the Ethernet AVB
>  interface contains.
>  
>  Required properties:
> -- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
> +- compatible: "renesas,etheravb-r8a7743" if the device is a part of R8A7743 SoC.
> +	      "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.

Please re-format like this:

- compatible: Must be one of:
...

So it's a one line change to add new compatibles.

>  	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
>  	      "renesas,etheravb-r8a7792" if the device is a part of R8A7792 SoC.
>  	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 5931e85..e35b30f 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1869,6 +1869,7 @@ static int ravb_mdio_release(struct ravb_private *priv)
>  }
>  
>  static const struct of_device_id ravb_match_table[] = {
> +	{ .compatible = "renesas,etheravb-r8a7743", .data = (void *)RCAR_GEN2 },
>  	{ .compatible = "renesas,etheravb-r8a7790", .data = (void *)RCAR_GEN2 },
>  	{ .compatible = "renesas,etheravb-r8a7794", .data = (void *)RCAR_GEN2 },
>  	{ .compatible = "renesas,etheravb-rcar-gen2", .data = (void *)RCAR_GEN2 },
> -- 
> 1.9.1
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
