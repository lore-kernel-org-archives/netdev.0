From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Add SG support for Zynq SOC family
Date: Mon, 6 Jul 2015 10:06:35 +0200
Message-ID: <559A370B.9050108@atmel.com>
References: <1436157173-27278-1-git-send-email-punnaia@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <harinik@xilinx.com>,
	<michals@xilinx.com>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436157173-27278-1-git-send-email-punnaia@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 06/07/2015 06:32, Punnaiah Choudary Kalluri a =E9crit :
> Enable SG support for Zynq SOC family devices.
>=20
> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index caeb395..a4e3f86 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2741,8 +2741,7 @@ static const struct macb_config emac_config =3D=
 {
> =20
> =20
>  static const struct macb_config zynqmp_config =3D {
> -	.caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE =
|
> -		MACB_CAPS_JUMBO,
> +	.caps =3D MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
>  	.dma_burst_length =3D 16,
>  	.clk_init =3D macb_clk_init,
>  	.init =3D macb_init,
> @@ -2750,8 +2749,7 @@ static const struct macb_config zynqmp_config =3D=
 {
>  };
> =20
>  static const struct macb_config zynq_config =3D {
> -	.caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE =
|
> -		MACB_CAPS_NO_GIGABIT_HALF,
> +	.caps =3D MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_NO_GIGABIT_H=
ALF,
>  	.dma_burst_length =3D 16,
>  	.clk_init =3D macb_clk_init,
>  	.init =3D macb_init,
>=20


--=20
Nicolas Ferre
