From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev 3/5] wl3501_cs: Switch to d80211.h
Date: Sun, 23 Jul 2006 20:43:26 -0700
Message-ID: <200607232043.31563.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1368933.RmMkvY0d4j";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	acme@conectiva.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:42470 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751393AbWGXDyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 23:54:10 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1368933.RmMkvY0d4j
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

wl3501_cs: Switch to d80211.h

This patch "converts" the wl3501_cs driver to use d80211.h instead
of ieee80211.h.

=46rom: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/wl3501.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/wl3501.h b/drivers/net/wireless/wl3501.h
index 65ceb08..caff8f5 100644
=2D-- a/drivers/net/wireless/wl3501.h
+++ b/drivers/net/wireless/wl3501.h
@@ -2,7 +2,7 @@ #ifndef __WL3501_H__
 #define __WL3501_H__
=20
 #include <linux/spinlock.h>
=2D#include <net/ieee80211.h>
+#include <net/d80211.h>
=20
 /* define for WLA 2.0 */
 #define WL3501_BLKSZ 256
@@ -548,7 +548,7 @@ struct wl3501_80211_tx_plcp_hdr {
=20
 struct wl3501_80211_tx_hdr {
 	struct wl3501_80211_tx_plcp_hdr	pclp_hdr;
=2D	struct ieee80211_hdr_4addr		mac_hdr;
+	struct ieee80211_hdr		mac_hdr;
 } __attribute__ ((packed));
=20
 /*

--nextPart1368933.RmMkvY0d4j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExEHjT3Oqt9AH4aERAvZYAKCDHX9FyMuv0l0doZ0wHhKoK7gRZgCghkAw
GG76Le8v6+DouSBBT34mIj8=
=V6m6
-----END PGP SIGNATURE-----

--nextPart1368933.RmMkvY0d4j--
