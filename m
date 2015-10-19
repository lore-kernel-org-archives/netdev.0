From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net, can, ti_hecc: fix a run time warn_on.
Date: Mon, 19 Oct 2015 08:34:11 +0200
Message-ID: <56248EE3.4000103@pengutronix.de>
References: <1445235739-26537-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Ndgl41pM3l6T52adO9SGWPvSrEIUC3DV3"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: Heiko Schocher <hs@denx.de>, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1445235739-26537-1-git-send-email-hs@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ndgl41pM3l6T52adO9SGWPvSrEIUC3DV3
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/19/2015 08:22 AM, Heiko Schocher wrote:
> This patch fixes a warning in clk_enable by calling
> clk_prepare_enable instead.

What about the corresponding clk_disable_unprepare()?

Marc

>=20
> Signed-off-by: Heiko Schocher <hs@denx.de>
> ---
>=20
>  drivers/net/can/ti_hecc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index cf345cb..c08e8ea 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -951,7 +951,7 @@ static int ti_hecc_probe(struct platform_device *pd=
ev)
>  	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>  		HECC_DEF_NAPI_WEIGHT);
> =20
> -	clk_enable(priv->clk);
> +	clk_prepare_enable(priv->clk);
>  	err =3D register_candev(ndev);
>  	if (err) {
>  		dev_err(&pdev->dev, "register_candev() failed\n");
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Ndgl41pM3l6T52adO9SGWPvSrEIUC3DV3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJI7jAAoJEP5prqPJtc/Hj6oH/j17cxpogxqKys9avv3oj/+z
l32c5Svz5h/Q4HxeGRiodsmTKycFQK1s2M/DQx643h1h33Zq0YKgV5BZqYrHjpfo
aBZpsG7dlNsaDwqsOGp/bisXLT3zbh/ykv3iq6cOpG9mQYsih5TA28NBC+Z8JbOg
s4fTk0QnaSwqpclfmeAM3IJ4bu+8vna0hfJRG+zkZSB5PApbt6qz6pv+tarCMm/T
5WgOUx0l4B9Foq3Tvc+KibscTrAgksLAjfq5tV+rloKVoj7kFyniioWXYDsN+MVp
HlaeZwAlsdAzbqm6mHdV41YSQtAyy1beMMxITBwhWp20PqlX3XvKKqakc8bodPQ=
=7q9x
-----END PGP SIGNATURE-----

--Ndgl41pM3l6T52adO9SGWPvSrEIUC3DV3--
