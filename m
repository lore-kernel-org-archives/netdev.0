From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/4] can: m_can: Update documentation to mention new
 fixed transceiver binding
Date: Mon, 24 Jul 2017 14:50:54 -0500
Message-ID: <20170724195054.or7vsl5mtvgh2tba@rob-hp-laptop>
References: <20170719233654.25908-1-fcooper@ti.com>
 <20170719233654.25908-4-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org
To: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170719233654.25908-4-fcooper-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 19, 2017 at 06:36:53PM -0500, Franklin S Cooper Jr wrote:
> Add information regarding fixed transceiver binding. This is especially
> important for MCAN since the IP allows CAN FD mode to run significantly
> faster than what most transceivers are capable of.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/can/m_can.txt | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
> index 9e33177..4440e4b 100644
> --- a/Documentation/devicetree/bindings/net/can/m_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/m_can.txt
> @@ -43,6 +43,11 @@ Required properties:
>  			  Please refer to 2.4.1 Message RAM Configuration in
>  			  Bosch M_CAN user manual for details.
>  
> +Optional properties:
> +- fixed-transceiver	: Fixed-transceiver subnode describing maximum speed
> +			  that can be used for CAN and/or CAN-FD modes.  See
> +			  Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
> +			  for details.
>  Example:
>  SoC dtsi:
>  m_can1: can@020e8000 {
> @@ -64,4 +69,9 @@ Board dts:
>  	pinctrl-names = "default";
>  	pinctrl-0 = <&pinctrl_m_can1>;
>  	status = "enabled";
> +
> +	fixed-transceiver@0 {

unit-address should have corresponding reg prop or unit-address should 
be dropped.

> +		max-arbitration-speed = <1000000>;
> +		max-data-speed = <5000000>;
> +	};
>  };
> -- 
> 2.10.0
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
