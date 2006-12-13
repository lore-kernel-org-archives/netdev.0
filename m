From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/14] d80211: add mising sta_info_put function
Date: Wed, 13 Dec 2006 17:41:43 +0100 (CET)
Message-ID: <20061213164143.943733AA6C0@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57259 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965007AbWLMRIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:53 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mohamed Abbas <mabbas@linux.intel.com>

This is small patch adding missing sta_info_put function.

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

6b29100c7e405c835eac8ebff2ff11774763da05
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 416d92e..1643216 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -3048,6 +3048,7 @@ static struct iw_statistics *ieee80211_g
 		wstats->qual.qual = 100*tmp_qual/local->hw.maxssi;
 		wstats->qual.noise = sta->last_noise;
 		wstats->qual.updated = IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
+		sta_info_put(sta);
 	}
 	return wstats;
 }
-- 
1.3.0

