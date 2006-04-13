From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 5/6] ieee80211: replace debug IEEE80211_WARNING with each own debug macro
Date: Thu, 13 Apr 2006 17:17:47 +0800
Message-ID: <20060413091747.GA28671@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:42672 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964835AbWDMJYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:24:52 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_rx.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

7a5148115c33ea94ff352a305ad2b2646a573219
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 0d18742..2bf567f 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -1690,8 +1690,8 @@ void ieee80211_rx_mgt(struct ieee80211_d
 				     WLAN_FC_GET_STYPE(le16_to_cpu
 						       (header->frame_ctl)));
 
-		IEEE80211_WARNING("%s: IEEE80211_REASSOC_REQ received\n",
-				  ieee->dev->name);
+		IEEE80211_DEBUG_MGMT("%s: IEEE80211_REASSOC_REQ received\n",
+				     ieee->dev->name);
 		if (ieee->handle_reassoc_request != NULL)
 			ieee->handle_reassoc_request(ieee->dev,
 						    (struct ieee80211_reassoc_request *)
@@ -1703,8 +1703,8 @@ void ieee80211_rx_mgt(struct ieee80211_d
 				     WLAN_FC_GET_STYPE(le16_to_cpu
 						       (header->frame_ctl)));
 
-		IEEE80211_WARNING("%s: IEEE80211_ASSOC_REQ received\n",
-				  ieee->dev->name);
+		IEEE80211_DEBUG_MGMT("%s: IEEE80211_ASSOC_REQ received\n",
+				     ieee->dev->name);
 		if (ieee->handle_assoc_request != NULL)
 			ieee->handle_assoc_request(ieee->dev);
 		break;
@@ -1720,10 +1720,10 @@ void ieee80211_rx_mgt(struct ieee80211_d
 		IEEE80211_DEBUG_MGMT("received UNKNOWN (%d)\n",
 				     WLAN_FC_GET_STYPE(le16_to_cpu
 						       (header->frame_ctl)));
-		IEEE80211_WARNING("%s: Unknown management packet: %d\n",
-				  ieee->dev->name,
-				  WLAN_FC_GET_STYPE(le16_to_cpu
-						    (header->frame_ctl)));
+		IEEE80211_DEBUG_MGMT("%s: Unknown management packet: %d\n",
+				     ieee->dev->name,
+				     WLAN_FC_GET_STYPE(le16_to_cpu
+						       (header->frame_ctl)));
 		break;
 	}
 }
-- 
1.2.6

