From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Tue, 4 Mar 2014 15:51:15 -0800
Message-ID: <1b9f22ac-4dde-4ecc-885a-3d8081157081@AM1EHSMHS012.ehs.local>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	<michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5254bfec-c6fd-4681-a34d-706d51e60fbb-+Ck8Kgl/v0+XHCJdrdq+zrjjLBE8jN/0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kedar,

On Tue, 2014-03-04 at 06:50PM +0530, Kedareswara rao Appana wrote:
> This patch adds xilinx CAN controller support.
> This driver supports both ZYNQ CANPS and Soft IP
> AXI CAN controller.
>=20
[...]
> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt=
 b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> new file mode 100644
> index 0000000..0e57103
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> @@ -0,0 +1,45 @@
> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
> +---------------------------------------------------------
> +
> +Required properties:
> +- compatible		: Should be "xlnx,zynq-can-1.00.a" for Zynq CAN
> +			  controllers and "xlnx,axi-can-1.00.a" for Axi CAN
> +			  controllers.
> +- reg			: Physical base address and size of the Axi CAN/Zynq
> +			  CANPS registers map.
> +- interrupts		: Property with a value describing the interrupt
> +			  number.
> +- interrupt-parent	: Must be core interrupt controller
> +- clock-names		: List of input clock names - "ref_clk", "aper_clk"

Let's reconsider these names. These are rather Zynq specific names. Doe=
s
the IP documentation use these as well? The names should match the
naming used for the IP, rather than the SOC. Is this the correct data s=
heet:
http://www.xilinx.com/support/documentation/ip_documentation/axi_can/v1=
_03_a/ds791_axi_can.pdf
? According to that the names should rather be 's_axi_aclk' and
'can_clk', IMHO.

	S=C3=B6ren


--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
