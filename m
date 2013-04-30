From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 30 Apr 2013 12:24:23 +1000
Message-ID: <20130430122423.ab57c82604f13f6773ef4aeb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__30_Apr_2013_12_24_23_+1000_XyLL3_xSVTg2TfTS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chen Gang <gang.chen@asianux.com>, Alan Ott <alan@signal11.us>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__30_Apr_2013_12_24_23_+1000_XyLL3_xSVTg2TfTS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/mac802154/mac802154.h between commit 2c1bbbffa0b6 ("net: mac802154:
comparision issue of type cast, finding by EXTRA_CFLAGS=3D-W") from the net
tree and commit 7dd43d356e73 ("mac802154: Do not try to resend failed
packets") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac802154/mac802154.h
index 703c121,5c9e021..0000000
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@@ -88,9 -88,7 +88,7 @@@ struct mac802154_sub_if_data=20
 =20
  #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, h=
w)
 =20
- #define MAC802154_MAX_XMIT_ATTEMPTS	3
-=20
 -#define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
 +#define MAC802154_CHAN_NONE		0xff /* No channel is assigned */
 =20
  extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
  extern struct ieee802154_mlme_ops mac802154_mlme_wpan;

--Signature=_Tue__30_Apr_2013_12_24_23_+1000_XyLL3_xSVTg2TfTS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRfytXAAoJEECxmPOUX5FE5+cP/2Tm5OeSWmVJju9Ji18oAZhm
zQVI0s9OkBPZRrCoeU39ADxOrvLh3p8eWEk4NZxJvU8SvpDFhJ80Rh7vBPh7cqQM
TFU5chWD38TLbby/hTjeuv4fKRMjrwmkizgzmRBdt7Vc0fsG1sxj8lqwyLB3JSiw
SYn+PcREo2OJoPs3liBkOq+rBors+duUq3lZBJ5q2g5tTjuGaj2nYImRCApM366d
ROTi1ZDbwN5wKsWTqAWTYtNXmTlLlYYW0d9022ByySaP/nL2MpaTBSKKfVHxxyHh
+hAyb4SS/dJcGNKeTFVvFOSv64LlDRFj9CgK9nqMePLYvqA9t005xqbVmOwKWjJH
hf2BdLVzB22qALI5sgFlaRRx1Oy1RWceKH3/QczRxaSggzzj3Mp8qMOeX6oJC+Bf
f3GuL/+Pm3aVtjsHVR/9lLnxLZ6FXABNdQ+9KJ8aDYgsCva/e6yI6bYx3/3HZ5KC
XcVxzquSpwF0oP3ZxBaxEMkdEwOHf5zCixy1To64SwOZw/4/ZrjWkqhWRDAGwGXd
xS9ZoM4ybjAuRuHYXNW1iBm+bDuMIGEl0zPdFo6Ta8BbVyQL41LoU7LhCYtNYdp2
9kUdt8Xt5MoDEcpxChtTTpm50ju3kLIke0fgsEyq36HuNHZx6nhJhXuAwEEGDcoy
CHhukkUEEFQcGqTwzHbn
=AHSv
-----END PGP SIGNATURE-----

--Signature=_Tue__30_Apr_2013_12_24_23_+1000_XyLL3_xSVTg2TfTS--
