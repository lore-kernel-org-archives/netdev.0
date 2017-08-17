From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 2/4] dt-bindings: can: can-transceiver: Document new
 binding
Date: Thu, 17 Aug 2017 10:10:36 -0500
Message-ID: <20170817151036.jyvg63oyhkne5jsg@rob-hp-laptop>
References: <20170810005916.27163-1-fcooper@ti.com>
 <20170810005916.27163-3-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        andrew@lunn.ch, sergei.shtylyov@cogentembedded.com,
        socketcan@hartkopp.net
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170810005916.27163-3-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2017 at 07:59:14PM -0500, Franklin S Cooper Jr wrote:
> Add documentation to describe usage of the new can-transceiver binding.
> This new binding is applicable for any CAN device therefore it exists as
> its own document.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
> Version 4 changes:
> Drop unit address.
> Switch from using fixed-transceiver to can-transceiver
> 
>  .../bindings/net/can/can-transceiver.txt           | 24 ++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/can/can-transceiver.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/can/can-transceiver.txt b/Documentation/devicetree/bindings/net/can/can-transceiver.txt
> new file mode 100644
> index 0000000..2c31dc0
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/can-transceiver.txt
> @@ -0,0 +1,24 @@
> +Generic CAN transceiver Device Tree binding
> +------------------------------
> +
> +CAN transceiver typically limits the max speed in standard CAN and CAN FD
> +modes. Typically these limitations are static and the transceivers themselves
> +provide no way to detect this limitation at runtime. For this situation,
> +the "can-transceiver" node can be used.
> +
> +Required Properties:
> + max-bitrate:	a positive non 0 value that determines the max
> +		speed that CAN/CAN-FD can run. Any other value
> +		will be ignored.
> +
> +Examples:
> +
> +Based on Texas Instrument's TCAN1042HGV CAN Transceiver
> +
> +m_can0 {
> +	....
> +	can-transceiver@ {

Need to drop the @ too. With that,

Acked-by: Rob Herring <robh@kernel.org>


> +		max-bitrate = <5000000>;
> +	};
> +	...
> +};
> -- 
> 2.9.4.dirty
> 
