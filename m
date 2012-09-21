From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: mscan-mpc5xxx: fix return value check in mpc512x_can_get_clock()
Date: Fri, 21 Sep 2012 10:09:51 +0200
Message-ID: <505C20CF.20508@pengutronix.de>
References: <CAPgLHd9fRAvQ77rD_PCp45XW9-FsBisUATOT00Je39nbv5o28A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2D9F288324D5187D24A039D9"
Cc: wg@grandegger.com, grant.likely@secretlab.ca,
	rob.herring@calxeda.com, yongjun_wei@trendmicro.com.cn,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAPgLHd9fRAvQ77rD_PCp45XW9-FsBisUATOT00Je39nbv5o28A@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2D9F288324D5187D24A039D9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/21/2012 09:09 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> In case of error, the function clk_get() returns ERR_PTR()
> and never returns NULL pointer. The NULL test in the error
> handling should be replaced with IS_ERR().
>=20
> dpatch engine is used to auto generated this patch.
> (https://github.com/weiyj/dpatch)
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied to can-next

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig2D9F288324D5187D24A039D9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBcIM8ACgkQjTAFq1RaXHOxzgCeNLxu1serLpCTc3MheBIOUoEM
DKwAmwYlhDORE13jmsaMTO6c1XE5ByJo
=VA+E
-----END PGP SIGNATURE-----

--------------enig2D9F288324D5187D24A039D9--
