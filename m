From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: m_can: Increase delay to ensure written INIT
 accepted
Date: Wed, 18 Nov 2015 11:25:56 +0100
Message-ID: <564C5234.40708@pengutronix.de>
References: <1447841049-5010-1-git-send-email-wenyou.yang@atmel.com>
 <1447841049-5010-2-git-send-email-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Tfs5nvLPd1QV9xRG0VAceNtRh2ppBO97d"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Wenyou Yang <wenyou.yang@atmel.com>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1447841049-5010-2-git-send-email-wenyou.yang@atmel.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Tfs5nvLPd1QV9xRG0VAceNtRh2ppBO97d
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/18/2015 11:04 AM, Wenyou Yang wrote:
> Increase the delay time until the value written to INIT can be
> read back to ensure that the previous value written to INIT has
> been accepted.
>=20
> Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>

The patch looks ok, can you please add to your commit message which SoCs
are affected by this problem.

> ---
>=20
>  drivers/net/can/m_can/m_can.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index ef65517..fd1caa0 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -320,7 +320,7 @@ static inline void m_can_config_endisable(const str=
uct m_can_priv *priv,
>  					  bool enable)
>  {
>  	u32 cccr =3D m_can_read(priv, M_CAN_CCCR);
> -	u32 timeout =3D 10;
> +	u32 timeout =3D 1000;
>  	u32 val =3D 0;
> =20
>  	if (enable) {
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Tfs5nvLPd1QV9xRG0VAceNtRh2ppBO97d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWTFI0AAoJEP5prqPJtc/HT68H/3BM8QvCvIf02LMseNb2Gmhq
zhmzh7Laf8IFZot53b7tycauAzichS65dVodqECxnv0p1UNv0lFOV7buuWu0a1Y4
R6mXwX4C30LisFnCiGNopGPJkdNCKMu4YiTdYmkZ9Fc+Bw8VLKR5aXV6Uu42EouG
YJ0X12V2eOPVqw0ITinPdFk8P8aK1ysl+G4YHeGuUSqEoXUtY8G4LimEoRPLPlxI
nP+65AicUt1ZNSUMco1wu9LOCNZ2Mca5MDeL8HjSyWQd8ddHJbNYhbTY0ztMRHyi
5zWiFFReUTIi45P/Y4Fx7LzSpSSpc3tjZTjmSwYSra8KY/KC2bOd12pSgCug2EM=
=RzKM
-----END PGP SIGNATURE-----

--Tfs5nvLPd1QV9xRG0VAceNtRh2ppBO97d--
