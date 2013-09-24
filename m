From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 01/10] can: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 09:37:12 +0200
Message-ID: <52414128.8030706@pengutronix.de>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="SG8AfUo3gTIoKWh5E6fcuER59cc8ViKKH"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SG8AfUo3gTIoKWh5E6fcuER59cc8ViKKH
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/24/2013 12:11 AM, Joe Perches wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
>=20
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Thx, added to linux-can-next. The patch will be included in the next
pull request to David.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--SG8AfUo3gTIoKWh5E6fcuER59cc8ViKKH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJBQSgACgkQjTAFq1RaXHOosQCdHzjND4NQOeaKoz6vv7RjjKsV
k4IAn2E/UoKcsCmrCXKBAIfRsqdXkP3t
=tYWu
-----END PGP SIGNATURE-----

--SG8AfUo3gTIoKWh5E6fcuER59cc8ViKKH--
