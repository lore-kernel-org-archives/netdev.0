From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
Date: Fri, 30 Sep 2011 11:38:11 +1000
Message-ID: <20110930113811.c2fa2d532dfa799a49c146f4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__30_Sep_2011_11_38_11_+1000_UsyJvIcijIPvUi6P"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Paul Mundt <lethal@linux-sh.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__30_Sep_2011_11_38_11_+1000_UsyJvIcijIPvUi6P
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, the next-20110929 build (various sh configs)
failed like this:

drivers/net/ethernet/renesas/sh_eth.c:601: error: 'THIS_MODULE' undeclared =
here (not in a function)
drivers/net/ethernet/renesas/sh_eth.c:1970: error: expected declaration spe=
cifiers or '...' before string constant
drivers/net/ethernet/renesas/sh_eth.c:1970: warning: data definition has no=
 type or storage class
drivers/net/ethernet/renesas/sh_eth.c:1970: warning: type defaults to 'int'=
 in declaration of 'MODULE_AUTHOR'
drivers/net/ethernet/renesas/sh_eth.c:1970: warning: function declaration i=
sn't a prototype
drivers/net/ethernet/renesas/sh_eth.c:1971: error: expected declaration spe=
cifiers or '...' before string constant
drivers/net/ethernet/renesas/sh_eth.c:1971: warning: data definition has no=
 type or storage class
drivers/net/ethernet/renesas/sh_eth.c:1971: warning: type defaults to 'int'=
 in declaration of 'MODULE_DESCRIPTION'
drivers/net/ethernet/renesas/sh_eth.c:1971: warning: function declaration i=
sn't a prototype
drivers/net/ethernet/renesas/sh_eth.c:1972: error: expected declaration spe=
cifiers or '...' before string constant
drivers/net/ethernet/renesas/sh_eth.c:1972: warning: data definition has no=
 type or storage class
drivers/net/ethernet/renesas/sh_eth.c:1972: warning: type defaults to 'int'=
 in declaration of 'MODULE_LICENSE'
drivers/net/ethernet/renesas/sh_eth.c:1972: warning: function declaration i=
sn't a prototype

Presumbly revealed by the module.h split up.  This file needs to include mo=
dule.h.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__30_Sep_2011_11_38_11_+1000_UsyJvIcijIPvUi6P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOhR2DAAoJEDMEi1NhKgbsY0IH/jPjbwV1cuPkvgvx2H5wtmV+
BS3F3QzQD50AVS6Adit7AtKzPQD/bpqRZ7+QMB/0rDN9iMcld3RCBu6vbRnUApcu
vDOkKEbt0LGrTIxMAfGF5NXgW90uhAn25rXorVkwyxv3DcVue8D/ZTYBg/1B0pUB
6Y9l332vht17a5T+c2SihqVxk29D+XjHPIKfeuIu7pRUukmi4VaIRu58QOFv1uel
ko4rEasLzWgx/QXu1BQ5t7I7CZRAy7ekNxyKAUXvVAmTitG2MPKF6d/DUzimWTol
FqrLEnbZedf2jS32h43p0k7CQXJlpvVN7VG4EipwFKUJjox+abN9ujBzWz7LKxg=
=ry9l
-----END PGP SIGNATURE-----

--Signature=_Fri__30_Sep_2011_11_38_11_+1000_UsyJvIcijIPvUi6P--
