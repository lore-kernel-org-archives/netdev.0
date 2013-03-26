From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Tue, 26 Mar 2013 11:51:20 +1100
Message-ID: <20130326115120.054f909e36cdc63b5607a8a8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__26_Mar_2013_11_51_20_+1100_0ajwKeG+fm0T/OIm"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__26_Mar_2013_11_51_20_+1100_0ajwKeG+fm0T/OIm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/wireless/core.h between commit f9f475292dbb ("cfg80211: always check
for scan end on P2P device") from the wireless tree and commit
812569699119 ("cfg80211/mac80211: disconnect on suspend") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Stephen Rothwell <sfr@canb.auug.org.au>

diff --cc net/wireless/core.h
index 5845c2b,d5d06fd..0000000
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@@ -503,9 -500,9 +500,12 @@@ int cfg80211_validate_beacon_int(struc
  void cfg80211_update_iface_num(struct cfg80211_registered_device *rdev,
  			       enum nl80211_iftype iftype, int num);
 =20
 +void cfg80211_stop_p2p_device(struct cfg80211_registered_device *rdev,
 +			      struct wireless_dev *wdev);
 +
+ void cfg80211_leave(struct cfg80211_registered_device *rdev,
+ 		    struct wireless_dev *wdev);
+=20
  #define CFG80211_MAX_NUM_DIFFERENT_CHANNELS 10
 =20
  #ifdef CONFIG_CFG80211_DEVELOPER_WARNINGS

--Signature=_Tue__26_Mar_2013_11_51_20_+1100_0ajwKeG+fm0T/OIm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRUPEIAAoJEECxmPOUX5FEKM4P/2m6YToka03lwMpadGhuswXP
E83mewAQ2hU1gq3wEBA8mlSbwYE93axxJK8gK0t/INwVIdJR1/5FtzyGrIPOXOaq
F1+1jQ7+a7D7SsDZ7HkKmj7ZcFdHp0OySEjlF25w2Yym2M1VyTQZnOkKzz1fmODx
FEwiGP+CrzNLHKrR9qf1HRlD/4l7T+GbEJnjKUF0swj3fr0M9kP6g62QJ+zMudJj
CwFf8e30Cn1bpBh+Q+zx9B1LwUAX4B3Z1/MMVX1lpQS76od/+Kcpil5N2Lqnvhd/
AHxTiFMAhRlDAbztwHoXKGn2jUoy/lyILOjO4ne2o1FHq04idOruk8KIBWTIRywK
f2F9xQTiD/vbbGM9MC20rjlbM26cHdyc8ql5Gz8D7dUpYWszrwQjIuKG3IB3c0vT
XJVio8gkbOXw0bIKzfvtqtNjyLVo5U4YDclJnbTohsZ8WWT/8/6EmK/sRyuSLDOK
uU0Em6/vupTB5mb+aWTlEAGFiuQEhTCUdiInsWK3TnDRmR3slTUND2pMBBri7V1l
5MzMZrvgYP1WOwOBTTT2rcDVmkTnhmg/3bSTaer7AX4CxeAaj0YVdcIwJoJdSrMH
BQRYSmDpsuvk2xFwxkyZzq+SreItIg264qxREo3D589Zza9GjCUkdLgAK/o/a+gl
KUceOF/dbjGuRoBJd35a
=+5kA
-----END PGP SIGNATURE-----

--Signature=_Tue__26_Mar_2013_11_51_20_+1100_0ajwKeG+fm0T/OIm--
