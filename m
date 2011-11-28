From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/4] can: cc770: add
 driver core for the Bosch CC770 and Intel AN82527
Date: Mon, 28 Nov 2011 15:18:25 +0100
Message-ID: <4ED39831.4060008@pengutronix.de>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-2-git-send-email-wg@grandegger.com>
	<4ED3704D.5020903@pengutronix.de> <4ED3922A.50704@grandegger.com>
	<4ED3941D.3070302@pengutronix.de> <4ED3966E.7080609@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1930834364814412534=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED3966E.7080609-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============1930834364814412534==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD3A04D58A975B8B45DF19976"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD3A04D58A975B8B45DF19976
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/28/2011 03:10 PM, Wolfgang Grandegger wrote:

>>>   enum {
>>> 	CC770_OBJ_RX0 =3D 0,	/* for receiving normal messages */
>>> 	CC770_OBJ_RX1,		/* for receiving normal messages */
>>> 	CC770_OBJ_RX_RTR0,	/* for receiving remote transmission requests */
>>> 	CC770_OBJ_RX_RTR1,	/* for receiving remote transmission requests */
>>> 	CC770_OBJ_TX,		/* for sending messages */
>>> 	CC770_OBJ_MAX  <=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> ...then add a "," here :P
>=20
> Why?

Okay - here the following argument will be not valid :), because OBJ_MAX
will and has always to be the last element in the enum.

But if you don't have a _MAX argument and a new element will be added to
the enum, you'll have to change two lines: 1. add the missing "," 2. add
the new element. Diff will look better if the last element always has a "=
,".

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD3A04D58A975B8B45DF19976
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7TmDMACgkQjTAFq1RaXHOi8gCaAo2aweSO9ERFP+Nd8MK64N46
qGAAniLsZAZA88yX7w7A0w8mLsDnneYI
=BX4f
-----END PGP SIGNATURE-----

--------------enigD3A04D58A975B8B45DF19976--

--===============1930834364814412534==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============1930834364814412534==--
