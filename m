From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 3/4] [flexcan] Add of_match to platform_device definition.
Date: Fri, 05 Aug 2011 09:13:19 +0200
Message-ID: <4E3B980F.4030603@pengutronix.de>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
	<1312509979-13226-4-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4574798398306215700=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312509979-13226-4-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============4574798398306215700==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9610FAD94E862DBC11A278FC"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9610FAD94E862DBC11A278FC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/05/2011 04:06 AM, Robin Holt wrote:
> It looks like the of_device stuff got moved under the
> platform_device->driver and all we should need to do is define an of_ma=
tch
> to get a flexcan_probe call out.

Please rephrase this commit message, at it goes into the git tree.
Otherwise the patche looks good.

Marc
>=20
> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  drivers/net/can/flexcan.c |   13 ++++++++++++-
>  1 files changed, 12 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index 3417d0b..fbb61c6 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -1129,8 +1129,19 @@ static int __devexit flexcan_remove(struct platf=
orm_device *pdev)
>  	return 0;
>  }
> =20
> +static struct of_device_id flexcan_of_match[] =3D {
> +	{
> +		.compatible =3D "fsl,flexcan",
> +	},
> +	{},
> +};
> +
>  static struct platform_driver flexcan_driver =3D {
> -	.driver.name =3D DRV_NAME,
> +	.driver =3D {
> +		.name =3D DRV_NAME,
> +		.owner =3D THIS_MODULE,
> +		.of_match_table =3D flexcan_of_match,
> +	},
>  	.probe =3D flexcan_probe,
>  	.remove =3D __devexit_p(flexcan_remove),
>  };


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9610FAD94E862DBC11A278FC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk47mBIACgkQjTAFq1RaXHNQ4ACgkhjDhKilwfOOgY/y1+o9XeuW
2oIAniEY454GiYOoIBQLG7xx0fdmuy71
=Lkl9
-----END PGP SIGNATURE-----

--------------enig9610FAD94E862DBC11A278FC--

--===============4574798398306215700==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4574798398306215700==--
