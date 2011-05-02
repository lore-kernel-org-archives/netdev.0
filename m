From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 5/5] iproute2: add can-j1939 support
Date: Mon, 02 May 2011 15:21:10 +0200
Message-ID: <4DBEAFC6.7010308@pengutronix.de>
References: <20110427085330.GA757@kurt.e-circ.dyndns.org>
	<20110427090302.GF757@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8753245420691840928=="
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110427090302.GF757-ozGf4kBk5synFtIcQ8t7k3L8HoS0Hn3T@public.gmane.org>
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
--===============8753245420691840928==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA320603DFBCE0DCA58B74CA6"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA320603DFBCE0DCA58B74CA6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/27/2011 11:03 AM, Kurt Van Dijck wrote:
> Add j1939 support to iproute2
>=20
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
> ---
> diff --git a/Makefile b/Makefile
> index d1ace1f..06bf281 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -27,9 +27,12 @@ ADDLIB+=3Ddnet_ntop.o dnet_pton.o
>  #options for ipx
>  ADDLIB+=3Dipx_ntop.o ipx_pton.o
> =20
> +#options for j1939
> +ADDLIB+=3Dj1939.o
> +
>  CC =3D gcc
>  HOSTCC =3D gcc
> -CCOPTS =3D -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
                          ^^^^

why do you remove -O2?

> +CCOPTS =3D -D_GNU_SOURCE -Wstrict-prototypes -Wall
>  CFLAGS =3D $(CCOPTS) -I../include $(DEFINES)
>  YACCFLAGS =3D -d -t -v

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA320603DFBCE0DCA58B74CA6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2+r8oACgkQjTAFq1RaXHNS6QCcCAACABq9LUI+J5xQ0U6VeLDs
clEAnjqusuqjAFmKqnfScS2Qj/eho+vR
=c8v9
-----END PGP SIGNATURE-----

--------------enigA320603DFBCE0DCA58B74CA6--

--===============8753245420691840928==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8753245420691840928==--
