From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: document R8A77970 bindings
Date: Wed, 13 Sep 2017 09:39:02 +0200
Message-ID: <20170913073901.GE6756@verge.net.au>
References: <20170912200228.015376134@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170912200228.015376134@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2017 at 11:02:08PM +0300, Sergei Shtylyov wrote:
> R-Car V3M (R8A77970) SoC also has the R-Car gen3 compatible EtherAVB
> device, so document  the SoC specific bindings.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

> ---
> The patch is against DaveM's 'net-next.git' repo but I wouldn't mind if it's
> applied to 'net.git' instead. :-)

Personally I would prefer net-next, but I don't feel strongly about this.
If you want it considered for net then I think it is likely that you will
need to repost it with the appropriate patch prefix.

> 
>  Documentation/devicetree/bindings/net/renesas,ravb.txt |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
> ===================================================================
> --- net-next.orig/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -17,6 +17,7 @@ Required properties:
>  
>        - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
>        - "renesas,etheravb-r8a7796" for the R8A7796 SoC.
> +      - "renesas,etheravb-r8a77970" for the R8A77970 SoC.
>        - "renesas,etheravb-rcar-gen3" as a fallback for the above
>  		R-Car Gen3 devices.
>  
> @@ -40,7 +41,7 @@ Optional properties:
>  - interrupt-parent: the phandle for the interrupt controller that services
>  		    interrupts for this device.
>  - interrupt-names: A list of interrupt names.
> -		   For the R8A779[56] SoCs this property is mandatory;
> +		   For the R-Car Gen 3 SoCs this property is mandatory;
>  		   it should include one entry per channel, named "ch%u",
>  		   where %u is the channel number ranging from 0 to 24.
>  		   For other SoCs this property is optional; if present
> 
