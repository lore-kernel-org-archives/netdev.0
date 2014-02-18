From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 18 Feb 2014 12:48:20 +1100
Message-ID: <20140218124820.f6a645fa960d0b3bc11d0745@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__18_Feb_2014_12_48_20_+1100_hA3ZDidI4/gHhoem"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Bohac <jiri@boha.cz>, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__18_Feb_2014_12_48_20_+1100_hA3ZDidI4/gHhoem
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/bonding/bond_3ad.h between commit 163c8ff30dbe ("bonding:
802.3ad: make aggregator_identifier bond-private") from the net tree and
commit 2ea24f2ecfdc ("bonding: Convert c99 comments") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/bonding/bond_3ad.h
index f4dd9592ac62,3b97fe487dca..000000000000
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@@ -251,9 -251,8 +251,9 @@@ struct ad_system=20
  #define SLAVE_AD_INFO(slave) ((slave)->ad_info)
 =20
  struct ad_bond_info {
- 	struct ad_system system;	    /* 802.3ad system structure */
- 	u32 agg_select_timer;	    // Timer to select aggregator after all adapte=
r's hand shakes
+ 	struct ad_system system;	/* 802.3ad system structure */
+ 	u32 agg_select_timer;		/* Timer to select aggregator after all adapter's=
 hand shakes */
 +	u16 aggregator_identifier;
  };
 =20
  struct ad_slave_info {

--Signature=_Tue__18_Feb_2014_12_48_20_+1100_hA3ZDidI4/gHhoem
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTArvvAAoJEMDTa8Ir7ZwVVU0P/0AogdyUEVXJV41+o0cDvuUo
z9akWGVeESpaqvLEgWt9QBDSG872VEkkAKpKWj7o679+TFysUiLbgyA1HgLxBPWU
7V1E795uzaC6W4k6OXXSm6Aqnbvs2kjb58O5R7YuPxKoF6P00/iNKtd5M9w+Puue
xgM5fkNbZ97HSRk/bRkfyB2OCLxfGeDKE2bZSPMDZ+XQTldS8Gv4cIm6vnNHw5Ks
C310mJAkXDoGHL5IA5mncTGNztlwx87QDrIny+vJiv5Tmc1Tvucg97yTrerquccn
3yzpw7liqoUdUxNKLaUiL8qqoVCWeWQgrfnDibvMP/jQ2fEE5G2/p//D/T+THl5M
BEkBh4uGRoP1O18HZ+twAWuX5SNDqAlvGsCcvyqHkhCePNt8snDCnHnX+79lbDa3
8h0N3n/i+xdkSxA+lJ7NXiF1gtlt3QSxDHjJ0wQ1cJ54zR/qZHXCbSyc4P73RtF8
6Wx+2QLMTaH+GkE2IZ4XC5NxgjJZzrmVR48TZDJa85B/cUi9927hE2FCMtTCWswp
pr0urJnvFb4mj95I8ujpic+h+Nl/UFfJoy9/OntsWjYFociFVazhbvVwj1NckfeZ
MMdse0ylCkKH0iP8ZXJ3XGIRbvM3979vjPbVznWkhynOnTGy3HgqDHispTyUMeMb
f5SLn3XYEIcliBc/u3/P
=LVK3
-----END PGP SIGNATURE-----

--Signature=_Tue__18_Feb_2014_12_48_20_+1100_hA3ZDidI4/gHhoem--
