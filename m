From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/12] d80211: small documentation fix
Date: Wed,  3 Jan 2007 19:05:16 +0100 (CET)
Message-ID: <20070103180516.6AD5D3AA7F1@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42229 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751015AbXACSFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:18 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_register_hwmode is allowed to be called before ieee80211_register_hw.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

acc7a635825dfc3b077630d8be621504ac71637e
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 9cecbd8..65a5d36 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -744,7 +744,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 
 /* Register hardware device to the IEEE 802.11 code and kernel. Low-level
  * drivers must call this function before using any other IEEE 802.11
- * function. */
+ * function except ieee80211_register_hwmode. */
 int ieee80211_register_hw(struct ieee80211_hw *hw);
 
 /* driver can use this and ieee80211_get_rx_led_name to get the
-- 
1.3.0

