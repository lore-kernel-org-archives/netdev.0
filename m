From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 26 Jun 2012 13:15:43 +1000
Message-ID: <20120626131543.21e4338894b19f5e02f8bdde@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__26_Jun_2012_13_15_43_+1000_wf+z6PNgcGMJe05v"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Per Ellefsen <Per.Ellefsen@stericsson.com>,
	=?UTF-8?B?IlNqdXIgQnLDpm5kZWxhbmQi?=
	<sjur.brandeland@stericsson.com>,
	Kim Lilliestierna <kim.xx.lilliestierna@stericsson.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__26_Jun_2012_13_15_43_+1000_wf+z6PNgcGMJe05v
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/caif/caif_hsi.c between commits 3935600a7f34 ("caif-hsi:
Bugfix - Piggyback'ed embedded CAIF frame lost") and 1fdc7630b2cb
("caif-hsi: Add missing return in error path") from the net tree and
commits 4e7bb59d49fb ("caif-hsi: Removed dead code") and c41254006377
("caif-hsi: Add rtnl support") from the net-next tree.

I fixed them up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/caif/caif_hsi.c
index 4a27adb,1c2bd01..0000000
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@@ -693,8 -678,8 +678,6 @@@ static void cfhsi_rx_done(struct cfhsi=20
  			 */
  			memcpy(rx_buf, (u8 *)piggy_desc,
  					CFHSI_DESC_SHORT_SZ);
- 			if (desc_pld_len =3D=3D -EPROTO)
- 				goto out_of_sync;
 -			/* Mark no embedded frame here */
 -			piggy_desc->offset =3D 0;
  		}
  	}
 =20

--Signature=_Tue__26_Jun_2012_13_15_43_+1000_wf+z6PNgcGMJe05v
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP6SlfAAoJEECxmPOUX5FE3sMP/3UqdcTeF+hXfffFOhTflLTy
dJYT8zzIuwPNUcwqO4KJ10WBZAjtzla8QdTa7gH6/rLP8eAUJuz7p4qF1i/W4U7z
v+c0Uvy8tGXIbxltnkZgw3FNiOYPhneT1c2Ru3EfKsdJqd4CZfQ94aVe0/SyV/QR
JJhgk727sMhg7ojpLQMPCQRNfIoIBN28UqftWWJx3caK6ksx0ETJgWEiZMHVjmK6
x/CwVU/yb93yvf5WX534c2gQrIMxojw9Wyui3g44ri+repPe4R0C1mqi9dllhfw0
fjf5d6h1nLcNdypJVNdwY9j5OKIfoEqEwr+9fBK+jtiD7z40VT0Tl5F46pQpKap1
wIMQ7HVGBO+gPx+CEfG1Yg5ovkuoOFmzasscVrwmO9R/o50bgCOcyC8ZQhE7/zbf
YvwlP6rL8JNrzXIMVI2+1UU86jB88Z4eZdwwyofb3muW2ozcbzKm0bvMhDC/RaR7
h36c8Je5TLAtxs3116AER3GsXBbnWvwSPwYbbWZmgyFsfm617Ky/gsbMBfHITzTQ
TQDZ2uUT0tAXmeLYYiUFFO3CrV2tnp6g6NEbfzhDxdUhBgtzaipA+p65y8sVw62f
dGq3odeyIRGQvwawckr0AZwdeZsnJ5RBtWfrpWbKR8wxCnKCicha0yT8nqhvazme
ASHLPhNivvEe8A/P7rTy
=DiNS
-----END PGP SIGNATURE-----

--Signature=_Tue__26_Jun_2012_13_15_43_+1000_wf+z6PNgcGMJe05v--
