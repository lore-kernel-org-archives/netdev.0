From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: gw: use kmem_cache_free() instead of kfree()
Date: Tue, 09 Apr 2013 10:20:39 +0200
Message-ID: <5163CF57.1090309@pengutronix.de>
References: <CAPgLHd9eAfwJMJ9P5RqOKNP5kq87y61V7CTw2J--Ld8uHT0RrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2DTUXQLJHGOGFSCMDSOHL"
Cc: socketcan@hartkopp.net, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAPgLHd9eAfwJMJ9P5RqOKNP5kq87y61V7CTw2J--Ld8uHT0RrQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2DTUXQLJHGOGFSCMDSOHL
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 04/09/2013 08:16 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> memory allocated by kmem_cache_alloc() should be freed using
> kmem_cache_free(), not kfree().
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Thanks for catching this. Applied to can/master.
I've send a pull request to David, along with Oliver's Acked-by and
stable on Cc.

Thanks,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2DTUXQLJHGOGFSCMDSOHL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFjz1wACgkQjTAFq1RaXHMgVACfejVeOBXML1XalskjYRwa01f6
74sAn1Ekat5lHkhlxnzIT8Kc2ArW9l3J
=JD4g
-----END PGP SIGNATURE-----

------enig2DTUXQLJHGOGFSCMDSOHL--
