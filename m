From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the final tree (net-next
 tree related)
Date: Wed, 22 May 2013 15:55:37 +1000
Message-ID: <20130522155537.3cc0ee6254775cc88cf2218f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__22_May_2013_15_55_37_+1000_hcUSMTO/Jbxh5RdU"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emilio =?UTF-8?B?TMOzcGV6?= <emilio@elopez.com.ar>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__22_May_2013_15_55_37_+1000_hcUSMTO/Jbxh5RdU
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (sparc32 defconfig)
produced this warning:

drivers/net/ethernet/sun/sunbmac.c: In function 'bigmac_set_multicast':
drivers/net/ethernet/sun/sunbmac.c:998:6: warning: unused variable 'i' [-Wu=
nused-variable]

Introduced by commit bfd428daaf61 ("net: ethernet: sun: initialize
variables directly") from the net-next tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__22_May_2013_15_55_37_+1000_hcUSMTO/Jbxh5RdU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRnF3ZAAoJEECxmPOUX5FEp9kP/iKklmD7VavHhDBYmSiOpdDp
rZ8U8r0TNd+BHTHUPQHCreXCwKrEgTRnf00TTvfIDhI54ManvBLc5gjq7or3WNL/
xg+RGYO28uurwKjEbB+poQYTXuGA8hbmshg9NhTqLhnmfZPJ48SRcViOH8HaOpW5
0g38Y7ki1ckq6Le1ItNJZGAyE/4rdQTy+UoFVi9vPAlzppF8r6b/vhyNHfOyyIPv
Ys0YkSHG+5q75t2tZyDc6BEjlR95FkoiqzOETrFoB25gBab7QUeuWDusoxj+lYLO
wYc/G8jqIe67M6H+WhKwL6bN0RYFTGXRNCMf0+uqdcw9rSQjSlzCXyNHYop5bGDC
JvCThYEdJKnzNGo1d4dDRdAh3dy45LZL3QDhsC9OclYchzzCz262U5rf9NpfkVII
xLDn0WYUCEUHSbSJdci3RSwGU/PskkjBa4qbJRBWJg7RGKauK4w7/BBsL7OcYHuj
QrIlf+IuSzmkIiVcqptlKQnW58da3Y/VhadR40pD+UcxVpqFEwdCIBaIcxUvPq1G
Azc/65GATmubqeP9MHdkh6Zhy8V0NthBAlvzz/XqrBISqsZSJzc652uR5kKSlVVU
DpHWhmbE6mBgbmKjrqqc6J2vQLu0izUZGKfJV3UsPWBOR9IkGHtEMVZr/aBDf4fK
CdZbSM/GMebgMT+Kqh5w
=XI7o
-----END PGP SIGNATURE-----

--Signature=_Wed__22_May_2013_15_55_37_+1000_hcUSMTO/Jbxh5RdU--
