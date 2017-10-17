From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: check for null sk before deferencing it via the call
 to sock_net
Date: Tue, 17 Oct 2017 07:49:58 +0200
Message-ID: <8fdd94bd-da4e-784e-3832-6c1bb5e1f432@pengutronix.de>
References: <20170908150235.2931-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="kLkPTC453FQOl0tOSLf9lQ8J0w18CI4wj"
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S . Miller" <davem@davemloft.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170908150235.2931-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kLkPTC453FQOl0tOSLf9lQ8J0w18CI4wj
Content-Type: multipart/mixed; boundary="DTmUVp86E7IrRQu3rUON4iV83LvAcU0Tu";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Colin King <colin.king@canonical.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S . Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 netdev@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <8fdd94bd-da4e-784e-3832-6c1bb5e1f432@pengutronix.de>
Subject: Re: [PATCH] can: check for null sk before deferencing it via the call
 to sock_net
References: <20170908150235.2931-1-colin.king@canonical.com>
In-Reply-To: <20170908150235.2931-1-colin.king@canonical.com>

--DTmUVp86E7IrRQu3rUON4iV83LvAcU0Tu
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

On 09/08/2017 05:02 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>=20
> The assignment of net via call sock_net will dereference sk. This
> is performed before a sanity null check on sk, so there could be
> a potential null dereference on the sock_net call if sk is null.
> Fix this by assigning net after the sk null check. Also replace
> the sk =3D=3D NULL with the more usual !sk idiom.
>=20
> Detected by CoverityScan CID#1431862 ("Dereference before null check")
>=20
> Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM protoc=
ol")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to can.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--DTmUVp86E7IrRQu3rUON4iV83LvAcU0Tu--

--kLkPTC453FQOl0tOSLf9lQ8J0w18CI4wj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnlmgYACgkQHv7KIOw4
HPaRYAf+JpN6F+2pNi5nsnzqsjCdyc2Y6/tYqy+mACthmqkjAeETg3XsTRC4lq8b
Lk1llWrAY1CkgqJEZfP5YxUkPv/SKL00AoyCRYX3mfXCuLnsLRLSa42/A23as/rA
+A/+ULdyLn+bs+6sNmRJoNuNJzxdgBR50Mbm0QKa9NcJDgGt83EY8PhUwj7j3Lp9
MfLnKxPqe7e4EZP1zF1RaJ91s5pFXafZyExHLXRGaiiSDHJOQ8aiEPgE0V9e3pwa
XXpISOyxQOxE/jdo+MAwxvbQ4mHO0fYbT4I+3sLj4cxlfZp7qATPIePa9rU1pf4g
1+ZhNYPCPx/AJ4CKggtMx6Ob3QyKLg==
=uA+7
-----END PGP SIGNATURE-----

--kLkPTC453FQOl0tOSLf9lQ8J0w18CI4wj--
