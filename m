From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 7/7] drivers/net/can/cc770/cc770_platform.c: adjust suspicious
 bit operation
Date: Wed, 06 Jun 2012 23:52:18 +0200
Message-ID: <4FCFD112.1070106@pengutronix.de>
References: <1339018901-28439-1-git-send-email-Julia.Lawall@lip6.fr> <1339018901-28439-8-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF0B5B7A6CB9E6AD33DD9FC5D"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	kernel-janitors@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, Julia Lawall <julia@diku.dk>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1339018901-28439-8-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF0B5B7A6CB9E6AD33DD9FC5D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/06/2012 11:41 PM, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> CPUIF_DSC is 0x40, so it would seem that & is wanted rather than |.
>=20
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).
>=20
> Signed-off-by: Julia Lawall <julia@diku.dk>

Good catch, Joe Perches has already found and fixed that problem. It has
been fixed in:

    dc605db can: cc770: Fix likely misuse of | for &

The commit is currently in David's net/master, and scheduled for the
v3.5 release.

Regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF0B5B7A6CB9E6AD33DD9FC5D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/P0RUACgkQjTAFq1RaXHMcbQCgi/Wo716GQYPqfXM9K/0YXMeZ
84gAoIvJmxcoGBuSuklIYpbxP0e2zPyn
=8dej
-----END PGP SIGNATURE-----

--------------enigF0B5B7A6CB9E6AD33DD9FC5D--
