From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Wed, 26 Jul 2017 18:41:24 +0200
Message-ID: <20170726164124.GL12049@lunn.ch>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        sergei.shtylyov@cogentembedded.com, socketcan@hartkopp.net
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170724230521.1436-3-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 24, 2017 at 06:05:19PM -0500, Franklin S Cooper Jr wrote:
> Add documentation to describe usage of the new fixed transceiver binding.
> This new binding is applicable for any CAN device therefore it exists as
> its own document.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
> Version 2:
> Tweak commit message working
> Tweak wording for properties
> Drop unit addressing
> Give example if CAN-FD isn't supported
> 
>  .../bindings/net/can/fixed-transceiver.txt         | 42 ++++++++++++++++++++++
>  1 file changed, 42 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
> new file mode 100644
> index 0000000..dc7e3eb
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
> @@ -0,0 +1,42 @@
> +Fixed transceiver Device Tree binding
> +------------------------------
> +
> +CAN transceiver typically limits the max speed in standard CAN and CAN FD
> +modes. Typically these limitations are static and the transceivers themselves
> +provide no way to detect this limitation at runtime. For this situation,
> +the "fixed-transceiver" node can be used.
> +
> +Properties:
> +
> +Optional:
> + max-arbitration-speed: a positive non 0 value that determines the max
> +			speed that CAN can run in non CAN-FD mode or during the
> +			arbitration phase in CAN-FD mode.

Hi Franklin

Since this and the next property are optional, it is good to document
what happens when they are not in the DT blob. Also document what 0
means.

> +
> + max-data-speed:	a positive non 0 value that determines the max data rate
> +			that can be used in CAN-FD mode. A value of -1 implies
> +			CAN-FD is not supported by the transceiver.

-1 is ugly. I think it would be better to have a missing
max-data-speed property indicate that CAN-FD is not supported. And
maybe put 'fd' into the property name.

      Andrew
