From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 10/12] dt-bindings: net: document bcmgenet WoL
 interrupt
Date: Mon, 20 Mar 2017 17:09:43 -0500
Message-ID: <20170320220943.aubgkguoavuqskih@rob-hp-laptop>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-11-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org,
        jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170314004142.4746-11-opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 05:41:40PM -0700, Doug Berger wrote:
> A third interrupt cell can be provided to optionally specify
> the interrupt used for handling Wake on LAN events.
> 
> Typically the wake up handling uses a separate interrupt
> controller, so the interrupts-extended property is used to
> accommodate this.

Using interrupts vs. interrupts-extended is beyond the scope of the 
binding doc. IOW, documenting interrupts is enough and using
interrupts-extended is allowed.

> 
> Signed-off-by: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/brcm,bcmgenet.txt | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
> index 10587bdadbbe..01a70463cbc5 100644
> --- a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
> +++ b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
> @@ -4,9 +4,12 @@ Required properties:
>  - compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
>    "brcm,genet-v3", "brcm,genet-v4".
>  - reg: address and length of the register set for the device
> -- interrupts: must be two cells, the first cell is the general purpose
> -  interrupt line, while the second cell is the interrupt for the ring
> -  RX and TX queues operating in ring mode
> +- interrupts and/or interrupts-extended: must be two cells, the first cell
> +  is the general purpose interrupt line, while the second cell is the
> +  interrupt for the ring RX and TX queues operating in ring mode.  An
> +  optional third interrupt cell for Wake-on-LAN can be specified.

Does the generic wakeup source work for this?

> +  See Documentation/devicetree/bindings/interrupt-controller/interrupts.txt
> +  for information on the property specifics.
>  - phy-mode: see ethernet.txt file in the same directory
>  - #address-cells: should be 1
>  - #size-cells: should be 1
> -- 
> 2.11.1
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
