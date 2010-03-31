From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Wed, 31 Mar 2010 10:10:04 +0200
Message-ID: <20100331081004.GB23391@pengutronix.de>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com> <20100331075746.GO2241@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KFztAG8eRSV9hGtP"
Cc: Bryan Wu <bryan.wu@canonical.com>, gerg@uclinux.org,
	amit.kucheria@canonical.com, kernel-team@lists.ubuntu.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100331075746.GO2241@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> With rounding this would be:
>=20
> (clk_get_rate() + 4999999) / 5000000

Better use DIV_ROUND_UP(clk_get_rate(), 5000000)?

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--KFztAG8eRSV9hGtP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkuzA1wACgkQD27XaX1/VRvefwCcD/QU+dlkXWFsDrjDTt7idHPQ
/boAn3KKMX9GVpD2HgJpBU2YpElzNmPT
=IK7w
-----END PGP SIGNATURE-----

--KFztAG8eRSV9hGtP--
