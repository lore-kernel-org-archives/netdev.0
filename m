From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 09 Mar 2015 09:50:41 +0100
Message-ID: <54FD5EE1.6050402@pengutronix.de>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="uufltjp90vvaD8JXtke7snIARLsTNueoA"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uufltjp90vvaD8JXtke7snIARLsTNueoA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 09:48 AM, Michal Simek wrote:
> Remove Kconfig dependency and enable driver for
> all ARCHs.
>=20
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
> ---
>=20
> Test for all archs done by Kbuild test robot without any problem.
> ---
>  drivers/net/can/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 98d73aab52fe..f690c3fb3088 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -131,7 +131,6 @@ config CAN_RCAR
> =20
>  config CAN_XILINXCAN
>  	tristate "Xilinx CAN"
> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST

I think that's what COMPILE_TEST ist for?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--uufltjp90vvaD8JXtke7snIARLsTNueoA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU/V7oAAoJECte4hHFiupUnccP/it6vhaAYcICApkRYtss7PDa
BhUQ8/HybX0hpvQfnPsPDwgZae6ldcaAI172GTyeoolXF9eC8+dInqxq1VxtIs5z
fVUfTy92833XY77/Te6lorEJ9uCzMh1uwerF29QZvt1EIR0RgPWqq0d1VMxSsXCs
a7htcjwVHxD+3CBWGxVR5NfqDlOuWYq46KVoXNwlb6ebplIUu7j2IEpgDZ/vafkt
kJXyNd4OWhJ+2j6KzY0e5Kddc1jdCONnWvY12nRG5PwKrYGBdRhGYDtuRl2wH3Vl
MW1IaxkqWKcFXBZwoxm1r9sVMfpHfemiapOTN+q5COV6MnvACOJja69kEjTcLmgL
AavVc8bL5Hyt4GJxJKev5wSXebl3gxxouxaPD1Pc8sLrpdgy2nRjWGo+LFIwXBv8
sigCYkFqsf8MeR9GPI7oYz9WHq/OESBctgZLYWpfXQEWqbOiO9E55GGlELGSWuE9
XElzVL12WW5LprUVznXgn9QeoDFGYp9WS6VM3tGJTiS4Knc+OwjxFvxM6fD0rj/6
rZfkxEThaTAi4f/LJAOg4wZx9tCfl/XMtf4xZPWbKvD5qvGkglhxNMlRz2fZ4wnt
eaA4ZeATPee2gRJuWKJR7oyVd2t5t05vrxZJitThXTGCgoQ9ZcTaAWPnUj7B+7no
yHNrNdXmlQfHCq/ZpX/d
=q/bN
-----END PGP SIGNATURE-----

--uufltjp90vvaD8JXtke7snIARLsTNueoA--
