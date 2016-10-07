From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH][RESEND] dt-bindings: net: renesas-ravb: Add support for
 R8A7796 RAVB
Date: Fri, 7 Oct 2016 12:29:16 +0900
Message-ID: <20161007032915.GN13721@verge.net.au>
References: <1475599546-29209-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475599546-29209-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 04, 2016 at 07:45:46PM +0300, Laurent Pinchart wrote:
> Add a new compatible string for the R8A7796 (M3-W) RAVB.
> 
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
> Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

> ---
>  Documentation/devicetree/bindings/net/renesas,ravb.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> The patch has been posted to the linux-renesas-soc mailing list only, adding
> the netdev mailing list to get it upstreamed.
> 
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index c8ac222eac67..b519503be51a 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -10,6 +10,7 @@ Required properties:
>  	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
>  	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
>  	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
> +	      "renesas,etheravb-r8a7796" if the device is a part of R8A7796 SoC.
>  	      "renesas,etheravb-rcar-gen2" for generic R-Car Gen 2 compatible interface.
>  	      "renesas,etheravb-rcar-gen3" for generic R-Car Gen 3 compatible interface.
>  
> @@ -33,7 +34,7 @@ Optional properties:
>  - interrupt-parent: the phandle for the interrupt controller that services
>  		    interrupts for this device.
>  - interrupt-names: A list of interrupt names.
> -		   For the R8A7795 SoC this property is mandatory;
> +		   For the R8A779[56] SoCs this property is mandatory;
>  		   it should include one entry per channel, named "ch%u",
>  		   where %u is the channel number ranging from 0 to 24.
>  		   For other SoCs this property is optional; if present
> -- 
> Regards,
> 
> Laurent Pinchart
> 
