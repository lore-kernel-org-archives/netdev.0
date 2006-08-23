From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 16/21] d80211: Group EIDs by standard, add remaining 802.11d EIDs
Date: Wed, 23 Aug 2006 21:24:25 +0200 (CEST)
Message-ID: <20060823192425.6542F483B4@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30160 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965135AbWHWTYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:24 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This patch groups EIDs together by the 802.11 standard they were introduced in
and adds the remaining 802.11d EIDs. The spec where the QoS EID was
introduced still needs to be found. (does not appear to be 802.11e..) This
patch depends on the previous patch that converts the status/reason codes and
EIDs to enums.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211_mgmt.h |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

6b31161b5dbf014abc07eadfa473f921d9c313ea
diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
index 6981c6f..eb032de 100644
--- a/include/net/d80211_mgmt.h
+++ b/include/net/d80211_mgmt.h
@@ -192,9 +192,13 @@ enum ieee80211_eid {
 	WLAN_EID_CF_PARAMS = 4,
 	WLAN_EID_TIM = 5,
 	WLAN_EID_IBSS_PARAMS = 6,
-	WLAN_EID_COUNTRY = 7,
 	WLAN_EID_CHALLENGE = 16,
-/* EIDs defined as part fo 11h - starts */
+	/* 802.11d */
+	WLAN_EID_COUNTRY = 7,
+	WLAN_EID_HP_PARAMS = 8,
+	WLAN_EID_HP_TABLE = 9,
+	WLAN_EID_REQUEST = 10,
+	/* 802.11h */
 	WLAN_EID_PWR_CONSTRAINT = 32,
 	WLAN_EID_PWR_CAPABILITY = 33,
 	WLAN_EID_TPC_REQUEST = 34,
@@ -205,10 +209,11 @@ enum ieee80211_eid {
 	WLAN_EID_MEASURE_REPORT = 39,
 	WLAN_EID_QUIET = 40,
 	WLAN_EID_IBSS_DFS = 41,
-/* EIDs defined as part fo 11h - ends */
+	/* 802.11g */
 	WLAN_EID_ERP_INFO = 42,
-	WLAN_EID_RSN = 48,
 	WLAN_EID_EXT_SUPP_RATES = 50,
+	/* 802.11i */
+	WLAN_EID_RSN = 48,
 	WLAN_EID_WPA = 221,
 	WLAN_EID_GENERIC = 221,
 	WLAN_EID_VENDOR_SPECIFIC = 221,
-- 
1.3.0

