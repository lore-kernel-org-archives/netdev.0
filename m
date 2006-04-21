From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 17/17] d80211: fix AP interfaces
Date: Fri, 21 Apr 2006 22:11:48 +0200 (CEST)
Message-ID: <20060421201148.DB906482C2@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15751 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932411AbWDUULV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:21 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows interfaces of IEEE80211_IF_TYPE_MGMT type (wlan%dap interfaces)
to be put UP.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

906a789aa674216a18ad5dc13c0635bc5664b793
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index b199b9e..64cc66f 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1893,6 +1893,8 @@ static inline int identical_mac_addr_all
 {
 	return (type1 == IEEE80211_IF_TYPE_MNTR ||
 		type2 == IEEE80211_IF_TYPE_MNTR ||
+		type1 == IEEE80211_IF_TYPE_MGMT ||
+		type2 == IEEE80211_IF_TYPE_MGMT ||
 		(type1 == IEEE80211_IF_TYPE_AP &&
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
-- 
1.3.0

