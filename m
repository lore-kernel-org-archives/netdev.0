From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Wed, 7 Jul 2010 14:30:45 +1000
Message-ID: <20100707143045.0c472f5d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__7_Jul_2010_14_30_45_+1000_0o6T=ZOCeMRirle2"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jonas Bonn <jonas@southpole.se>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__7_Jul_2010_14_30_45_+1000_0o6T=ZOCeMRirle2
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (x86_64
allmodconfig) produced this warning:

drivers/net/ethoc.c: In function 'ethoc_init_ring':
drivers/net/ethoc.c:302: warning: assignment makes integer from pointer wit=
hout a cast

Introduced by commit f8555ad0cfb0ba6cbc8729f337341fb11c82db89 ("ethoc:
Write bus addresses to registers").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__7_Jul_2010_14_30_45_+1000_0o6T=ZOCeMRirle2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMNAL1AAoJEDMEi1NhKgbsLJwH/3G76rFeIds4FeW7yXK5SMe7
buiRLklzCVeUOP+DeNHCjFWH0+CXl5cEcZer8ef974VVi/PJezqn2Ef5vlH8Fs82
oJOdaFtb0DFXd57TLcSvFoXQUbS5/4j6l4QX+hKhF92ZXHJ1b8YBROLvuR0LRr0N
vbEtbnghp1P/WlYRmD4u5OSGaw5xpkwiHpL6OQNtmMdFuQQLIkoruJzHUngEI25s
YncF9LcebmCQOyn4yCwOynrDVWigSf9G9aflDcpm0Y91ybqobxU9KJcWVxGP0qfB
pzSP+0D84bVS3wQXV3rRa+/AKbqHlt0kC0EjrxA9VPD9hvNyBTDPji0gbV1uyT0=
=jH/W
-----END PGP SIGNATURE-----

--Signature=_Wed__7_Jul_2010_14_30_45_+1000_0o6T=ZOCeMRirle2--
