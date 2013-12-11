From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-12-11
Date: Wed, 11 Dec 2013 10:48:10 -0500
Message-ID: <20131211154810.GB7411@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Just one patch this time -- a fix from Felix Fietkau to fix the
duration calculation for non-aggregated packets in ath9k.  This is
a small change and it is obviously specific to ath9k.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 8afdd99a1315e759de04ad6e2344f0c5f17ecb1b:

  udp: ipv4: fix an use after free in __udp4_lib_rcv() (2013-12-10 22:58:40=
 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 33457ff7cdd48c54723ab8c550deec28dd904659:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-12-11 10:41:56 -0500)

----------------------------------------------------------------

Felix Fietkau (1):
      ath9k: fix duration calculation for non-aggregated packets

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

 drivers/net/wireless/ath/ath9k/xmit.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 09cdbcd09739..b5a19e098f2d 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1276,6 +1276,10 @@ static void ath_tx_fill_desc(struct ath_softc *sc, s=
truct ath_buf *bf,
 				if (!rts_thresh || (len > rts_thresh))
 					rts =3D true;
 			}
+
+			if (!aggr)
+				len =3D fi->framelen;
+
 			ath_buf_set_rate(sc, bf, &info, len, rts);
 		}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSqIk6AAoJEJctW/TcYTgG0HQP/2A982a2xUiISAHGSc82shSi
rRNc5+9xe7sz+249lsXW6ZJEbhd77KbhP5y8xVhF0U4RLQ9z62QRp2qQmg5rxS0r
3IaJSUf+AfLRafEQSMqxByW98NR2z73jURewRdKPMbNYCdBHhRFIHTlwXBZHVqaE
zulRYyRZ+Byt5bG82M89NUwG+iyD7iU9Wan+nyR3b7xAvfCy1jsDz+TAaOtm3eIL
+FEzcQyvnWD/TPngzEtH8jhGiKAzJlwjTSk9UEbU7t+KxOPJLGUj4uX8BdM8m9Ar
+UEh2X/EOIdb4nbRKGadFNq0/GWi6SdFQNWjpSCkTAP2f1Hh9wiTRZ56YB68JIcu
A4+zFArbsWqVX549Bnag4+W/7pSUXjouOB+zfE5a2k4qBiNBbGNRDkrsE4ENLWu0
/09wFQ+XB8Vey6dN45YSYdflpSJDiQAFtGzuXqRqNM7c8xxSblK+IHGKitspAZHx
lvGb0t5RQiRHkG863zN3+lrW79Y/frsQRBHoc2j4eZFWO3dpdtuycGZgxauvov+x
oamVChjNfvAc89ngfvxPHICRPKV7YBp0KfpYh8Yd6o2VpBHdVf2Sx4AOjKCil35R
edC7z2ISfpy1KZt3BcpcLWoKmkr6LUqh+yyOg3bb/wZ8+KOONlxeqq8aWMgmd0+U
R0gZZLPze8SHb1ElrWdy
=qyhn
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
