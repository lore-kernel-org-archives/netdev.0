From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/17] d80211: add IBSS and monitor interface types
Date: Fri, 21 Apr 2006 22:11:35 +0200 (CEST)
Message-ID: <20060421201135.3A51D482C5@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11655 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932397AbWDUULH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:07 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add constants for IBSS and monitor interface types. These constants are used
in subsequent patches.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_i.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

b5f3ee77e4da0c6cbe98000f1380d3df92a949d4
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ba72466..848afb7 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -259,6 +259,8 @@ #define IEEE80211_AUTH_ALG_LEAP BIT(2)
 #define IEEE80211_SUB_IF_TYPE_AP   0x00000000
 #define IEEE80211_SUB_IF_TYPE_MGMT 0x00000001
 #define IEEE80211_SUB_IF_TYPE_STA  0x00000002
+#define IEEE80211_SUB_IF_TYPE_IBSS 0x00000003
+#define IEEE80211_SUB_IF_TYPE_MNTR 0x00000004
 #define IEEE80211_SUB_IF_TYPE_WDS  0x5A580211
 #define IEEE80211_SUB_IF_TYPE_VLAN 0x00080211
 
-- 
1.3.0

