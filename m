From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v5 net-next 2/3] net: macb: Add NP4 macb config using
 USRIO_DISABLED
Date: Tue, 5 Jan 2016 14:45:31 +0100
Message-ID: <568BC8FB.30005@atmel.com>
References: <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
 <1452001158-20585-1-git-send-email-narmstrong@baylibre.com>
 <1452001158-20585-3-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <narmstrong@baylibre.com>, <davem@davemloft.net>,
	<harini.katakam@xilinx.com>, <boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<joshc@ni.com>, <devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452001158-20585-3-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/01/2016 14:39, Neil Armstrong a =E9crit :
> Declare a new NP4 SoC variant having USRIO_DISABLED as capability bit=
=2E
>=20
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>


> ---
>  drivers/net/ethernet/cadence/macb.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index fa53bc3..d12ee07 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2781,6 +2781,11 @@ static const struct macb_config emac_config =3D=
 {
>  	.init =3D at91ether_init,
>  };
> =20
> +static const struct macb_config np4_config =3D {
> +	.caps =3D MACB_CAPS_USRIO_DISABLED,
> +	.clk_init =3D macb_clk_init,
> +	.init =3D macb_init,
> +};
> =20
>  static const struct macb_config zynqmp_config =3D {
>  	.caps =3D MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
> @@ -2801,6 +2806,7 @@ static const struct of_device_id macb_dt_ids[] =
=3D {
>  	{ .compatible =3D "cdns,at32ap7000-macb" },
>  	{ .compatible =3D "cdns,at91sam9260-macb", .data =3D &at91sam9260_c=
onfig },
>  	{ .compatible =3D "cdns,macb" },
> +	{ .compatible =3D "cdns,np4-macb", .data =3D &np4_config },
>  	{ .compatible =3D "cdns,pc302-gem", .data =3D &pc302gem_config },
>  	{ .compatible =3D "cdns,gem", .data =3D &pc302gem_config },
>  	{ .compatible =3D "atmel,sama5d2-gem", .data =3D &sama5d2_config },
>=20


--=20
Nicolas Ferre
