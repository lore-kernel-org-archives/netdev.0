From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 3/6] Documentation: devicetree: net: add NS2 bindings
 to amac
Date: Mon, 31 Oct 2016 01:20:35 -0500
Message-ID: <20161031062035.5hzolwhjnwcs72kg@rob-hp-laptop>
References: <1477688219-3871-1-git-send-email-jon.mason@broadcom.com>
 <1477688219-3871-4-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1477688219-3871-4-git-send-email-jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2016 at 04:56:56PM -0400, Jon Mason wrote:
> Signed-off-by: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/brcm,amac.txt | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,amac.txt b/Documentation/devicetree/bindings/net/brcm,amac.txt
> index ba5ecc1..f2b194e 100644
> --- a/Documentation/devicetree/bindings/net/brcm,amac.txt
> +++ b/Documentation/devicetree/bindings/net/brcm,amac.txt
> @@ -2,11 +2,12 @@ Broadcom AMAC Ethernet Controller Device Tree Bindings
>  -------------------------------------------------------------
>  
>  Required properties:
> - - compatible:	"brcm,amac" or "brcm,nsp-amac"
> + - compatible:	"brcm,amac", "brcm,nsp-amac", or "brcm,ns2-amac"

One per line is preferred.

>   - reg:		Address and length of the GMAC registers,
>  		Address and length of the GMAC IDM registers
> +		Address and length of the NIC Port Manager registers (optional)
>   - reg-names:	Names of the registers.  Must have both "amac_base" and
> -		"idm_base"
> +		"idm_base". "nicpm_base" is optional (required for NS2)

Is nicpm_base optional on some SoCs? If not just say which ones it 
applies to. A separate line will make that clearer.

_base is kind of redundant too, but it's already done.

>   - interrupts:	Interrupt number
>  
>  Optional properties:
> -- 
> 2.7.4
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
