From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] d80211: Group EIDs by standard, add remaining 802.11d EIDs
Date: Sat, 19 Aug 2006 13:05:10 -0700
Message-ID: <200608191305.15581.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2197392.OhCnhekr5c";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:3050 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751116AbWHSUFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Aug 2006 16:05:12 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2197392.OhCnhekr5c
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: Group EIDs by standard, add remaining 802.11d EIDs

This patch groups EIDs together by the 802.11 standard they were introduced=
 in=20
and adds the remaining 802.11d EIDs. The spec where the QoS EID was=20
introduced still needs to be found. (does not appear to be 802.11e..) This=
=20
patch depends on the previous patch that converts the status/reason codes a=
nd=20
EIDs to enums.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 include/net/d80211_mgmt.h |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
index 6981c6f..eb032de 100644
=2D-- a/include/net/d80211_mgmt.h
+++ b/include/net/d80211_mgmt.h
@@ -192,9 +192,13 @@ enum ieee80211_eid {
 	WLAN_EID_CF_PARAMS =3D 4,
 	WLAN_EID_TIM =3D 5,
 	WLAN_EID_IBSS_PARAMS =3D 6,
=2D	WLAN_EID_COUNTRY =3D 7,
 	WLAN_EID_CHALLENGE =3D 16,
=2D/* EIDs defined as part fo 11h - starts */
+	/* 802.11d */
+	WLAN_EID_COUNTRY =3D 7,
+	WLAN_EID_HP_PARAMS =3D 8,
+	WLAN_EID_HP_TABLE =3D 9,
+	WLAN_EID_REQUEST =3D 10,
+	/* 802.11h */
 	WLAN_EID_PWR_CONSTRAINT =3D 32,
 	WLAN_EID_PWR_CAPABILITY =3D 33,
 	WLAN_EID_TPC_REQUEST =3D 34,
@@ -205,10 +209,11 @@ enum ieee80211_eid {
 	WLAN_EID_MEASURE_REPORT =3D 39,
 	WLAN_EID_QUIET =3D 40,
 	WLAN_EID_IBSS_DFS =3D 41,
=2D/* EIDs defined as part fo 11h - ends */
+	/* 802.11g */
 	WLAN_EID_ERP_INFO =3D 42,
=2D	WLAN_EID_RSN =3D 48,
 	WLAN_EID_EXT_SUPP_RATES =3D 50,
+	/* 802.11i */
+	WLAN_EID_RSN =3D 48,
 	WLAN_EID_WPA =3D 221,
 	WLAN_EID_GENERIC =3D 221,
 	WLAN_EID_VENDOR_SPECIFIC =3D 221,

--nextPart2197392.OhCnhekr5c
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE5277T3Oqt9AH4aERAuuDAKDPEn/7OCg3gNfH4kGY74zxIdJCfQCfYgJu
2yyNhcP2o97C2QXupyvA79o=
=hc3Q
-----END PGP SIGNATURE-----

--nextPart2197392.OhCnhekr5c--
