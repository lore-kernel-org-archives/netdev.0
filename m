From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] Bluetooth: Silence static checker warning.
Date: Fri, 2 Mar 2012 14:04:20 +0300
Message-ID: <20120302110420.GH22598@mwanda>
References: <1330537602.3392.101.camel@aeonflux>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6E88@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cfJ13FhsvNR/yOpm"
Cc: Marcel Holtmann <marcel@holtmann.org>,
	santosh nayak <santoshprasadnayak@gmail.com>,
	padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Ville Tervo <ville.tervo@nokia.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E88@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cfJ13FhsvNR/yOpm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 02, 2012 at 09:15:37AM -0000, David Laight wrote:
> How long has this code been in tree?
> It isn't obvious to me that this change won't break code on BE systems
> where the application code is already fixing the endianness.
>=20

It looks like we've had an endian bug since last February.

b62f328b8f20a "Bluetooth: Add server socket support for LE
connection"

+               l2cap_pi(sk)->scid =3D la.l2_cid;

->scid was cpu endian.

regards,
dan carpenter

--cfJ13FhsvNR/yOpm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPUKkzAAoJEOnZkXI/YHqRADkP/217s0ztGrn66LSv/c5F1A4k
6cBasjmCmLkN/AE/BMwu6lQoSh/U+flf2SIgxT1ULuyni/FpJ+bVwn6flrOPaRzB
D+JPi5T3vEMnM6s8P2C6gVrwvCEPvzUhvgaCXgh6rmQO/OKq5H49RjyRuhWUb/jG
puXy4pFxr4AfLYuSS4I5xNfSPAec9dSX2q8a1PZnvlOkc/zj2uLeJh5dyFwDQWIc
RA31sMNUF6x1nLJ91HYfXuu9kJynQQeX8HCtxBU1Vn7Inc1EQ4HrqPkOgTaFBbo9
tL0i9uGcWGbzZYbZp5K6yPZyaY4M+fxjQNGMO+P14AKIZwJWNKkIiusNEasC18ea
gnm/SO+VNl8xLsAjJDcgyFmudGvFMgqkxY+vDK8Q2MP2qymJLigLzNkEUTq1c4Wx
X47Pob9mFSLZARCKE+FEIOInLcJjTnJzTNBYcS1s35wWJ7a8IZ94JheT6gEL+0xP
tmz3jdvOBHPzG+wkID31/JyTjRqERb749i9aiGF1Wy2pXSvwa8uKE47nDDw7zt4r
hjbsft9ubm+W0lt3ofw0TkL97A1wBLebTV/ZT/FDtBflyNYFmjXq/oEyqyF+vH1i
USciqxB3mp9znqp13k9ADR4OKzqJ15uk9LgT/jjHmXFgnOC7/3iALpSXfTHCqupA
woGcH+1N1MOFEKlxdzPP
=nrfy
-----END PGP SIGNATURE-----

--cfJ13FhsvNR/yOpm--
