From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] net: can: Disable flexcan driver build for big endian
 CPU on ARM
Date: Mon, 06 Jan 2014 14:23:16 +0100
Message-ID: <52CAAE44.1020100@pengutronix.de>
References: <1389014463-14649-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="r4VmuUdtCUcIAKBkMxcm5qUDFiJvP3pU8"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1389014463-14649-1-git-send-email-linux@roeck-us.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--r4VmuUdtCUcIAKBkMxcm5qUDFiJvP3pU8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/06/2014 02:21 PM, Guenter Roeck wrote:
> Building arm:allmodconfig fails with
>=20
> flexcan.c: In function 'flexcan_read':
> flexcan.c:243:2: error: implicit declaration of function 'in_be32'
> flexcan.c: In function 'flexcan_write':
> flexcan.c:248:2: error: implicit declaration of function 'out_be32'
>=20
> in_be32 and out_be32 do not (or no longer) exist for ARM targets.
> Disable the build for ARM on big endian CPUs.
>=20
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied to can-next.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--r4VmuUdtCUcIAKBkMxcm5qUDFiJvP3pU8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLKrkUACgkQjTAFq1RaXHORLgCePjh3+MZ4Qf9sD7beWOFTGlB4
cSYAn2Zxg2ixB4H3FV48AxjVoFgvsPPX
=cGTp
-----END PGP SIGNATURE-----

--r4VmuUdtCUcIAKBkMxcm5qUDFiJvP3pU8--
