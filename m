From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v2 3/3] ARM: zynq: DT: Use the zynq binding with macb
Date: Mon, 25 May 2015 12:14:47 -0700
Message-ID: <20150525191447.GV18303@xsjsorenbubuntu>
References: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
 <1432304531-23682-3-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432304531-23682-3-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-05-22 at 09:22AM -0500, Nathan Sullivan wrote:
> Use the new zynq binding for macb ethernet, since it will disable hal=
f
> duplex gigabit like the Zynq TRM says to do.
>=20
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> ---
>  arch/arm/boot/dts/zynq-7000.dtsi |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/arm/boot/dts/zynq-7000.dtsi b/arch/arm/boot/dts/zyn=
q-7000.dtsi
> index a5cd2ed..9ea54b3 100644
> --- a/arch/arm/boot/dts/zynq-7000.dtsi
> +++ b/arch/arm/boot/dts/zynq-7000.dtsi
> @@ -193,7 +193,7 @@
>  		};
> =20
>  		gem0: ethernet@e000b000 {
> -			compatible =3D "cdns,gem";
> +			compatible =3D "cdns,zynq-gem";

Please, prepend the new string to the compatible list. Don't just
replace it like this.

>  			reg =3D <0xe000b000 0x1000>;
>  			status =3D "disabled";
>  			interrupts =3D <0 22 4>;
> @@ -204,7 +204,7 @@
>  		};
> =20
>  		gem1: ethernet@e000c000 {
> -			compatible =3D "cdns,gem";
> +			compatible =3D "cdns,zynq-gem";

ditto

	S=C3=B6ren
