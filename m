From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] d80211: Fix WMM ACI to UP mapping
Date: Fri, 02 Feb 2007 17:15:54 +0800
Message-ID: <1170407754.6601.228.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John W.Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40216 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932852AbXBBJPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 04:15:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix WMM ACI to UP mapping according to IEEE 802.1d spec. Table 7-2.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 393a294..fabdef5 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -289,7 +289,7 @@ static void ieee80211_sta_wmm_params(struct
net_device *dev,
 		case 1:
 			queue = IEEE80211_TX_QUEUE_DATA3;
 			if (acm) {
-				local->wmm_acm |= BIT(1) | BIT(2);
+				local->wmm_acm |= BIT(0) | BIT(3);
 			}
 			break;
 		case 2:
@@ -308,7 +308,7 @@ static void ieee80211_sta_wmm_params(struct
net_device *dev,
 		default:
 			queue = IEEE80211_TX_QUEUE_DATA2;
 			if (acm) {
-				local->wmm_acm |= BIT(0) | BIT(3);
+				local->wmm_acm |= BIT(1) | BIT(2);
 			}
 			break;
 		}

