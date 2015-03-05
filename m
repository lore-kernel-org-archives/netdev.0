From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 6 Mar 2015 10:26:14 +1100
Message-ID: <20150306102614.206e5ec6@canb.auug.org.au>
References: <20150305134247.5a55e4db@canb.auug.org.au>
	<20150305.000158.1662853297584626367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/m_frNs=4qCu_Oun.GuKRmU."; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150305.000158.1662853297584626367.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/m_frNs=4qCu_Oun.GuKRmU.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 05 Mar 2015 00:01:58 -0500 (EST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 5 Mar 2015 13:42:47 +1100
>=20
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Thu, 5 Mar 2015 13:37:05 +1100
> > Subject: [PATCH] mpls: using vzalloc requires including vmalloc.h
> >=20
> > Fixes this build error:
> >=20
> > net/mpls/af_mpls.c: In function 'resize_platform_label_table':
> > net/mpls/af_mpls.c:767:4: error: implicit declaration of function 'vzal=
loc' [-Werror=3Dimplicit-function-declaration]
> >     labels =3D vzalloc(size);
> >     ^
> >=20
> > Fixes: 7720c01f3f59 ("mpls: Add a sysctl to control the size of the mpl=
s label table")
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> Applied, thanks Stephen.

I don't see it in net-next?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/m_frNs=4qCu_Oun.GuKRmU.
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU+OYbAAoJEMDTa8Ir7ZwVR2IQAITWu6ZSnTnJRAAxNtVYuiuk
E4oDHDFUGnFo5vpj4V3y1959Dg53gVLRyGZjyyBsYD7B1TuHtf6z3tdb7/C5qaAQ
6qQjAiWKdImY6eGl+OhWxC5BuN5kGTC7EZRsuNnOVycxosKyf5kp7kngT3WoUcNb
gS3fE+GQSqJtHRy2WkPuw1cm47FGUSii/g0/FTn4+9eEvGy5Wl3mz/pSNbbf4aBS
FhZY8RiaAO7k2zqe5qH6QUDHxNoFNILf4x6QIfnAWdOU65m2oBwIGCbpgz3f5mky
FKEGEWZJ9V8laN9jS/HzbvOPNbB1YcIYhIX2ftmhTc6BsuPhWhPd99+7g36mZ3xd
NNIDz02Cij9H6vj7PMfT1yIrVailqHb1IKg3U/l+yEpbleZZ3VcLx2SmKEmMy46a
p7KRasch9rrgiXTubD1+hjB4lx5SnHU2rBDZoXP8wQ0fNPXgd+FidJgzYT1mHz07
4IfUh6Embw1ucquEX0U5Gq1Bs+2dwA+QsEv9jqIe3b+buOO93gIpoC16u0BLsTNB
9MQd06/IT/APqay10SagfrCgb0o2d+WsxPRGYrYZxwu8nxoiOaFCfalXKffhiEX8
Qh8TczBlXcnzw3a82y9dv/uDpUiupQU/0jbYBEgYbu+Sbj+Apvy+hdRUWgve/zHe
GuGXE7IWZ+oNECj26w8c
=3Yf0
-----END PGP SIGNATURE-----

--Sig_/m_frNs=4qCu_Oun.GuKRmU.--
