From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch] can: c_can: precedence error in c_can_chip_config()
Date: Sun, 10 Jun 2012 19:52:50 +0200
Message-ID: <4FD4DEF2.6070802@pengutronix.de>
References: <20120609155150.GA6488@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDF9262DCE005C3D320965B72"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120609155150.GA6488@elgon.mountain>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDF9262DCE005C3D320965B72
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/09/2012 05:56 PM, Dan Carpenter wrote:
> (CAN_CTRLMODE_LISTENONLY & CAN_CTRLMODE_LOOPBACK) is (0x02 & 0x01) whic=
h
> is zero so the condition is never true.  The intent here was to test
> that both flags were set.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This is a static checker fix.  I'm not super familiar with the c_can
> code.

Good catch. Applied to can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDF9262DCE005C3D320965B72
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/U3vUACgkQjTAFq1RaXHNiSQCbBRNFpJ4t87JO60VXWO6gYQSt
qiEAni/2FlRasJZcbIRpE6LzyWYgEUz8
=TViJ
-----END PGP SIGNATURE-----

--------------enigDF9262DCE005C3D320965B72--
