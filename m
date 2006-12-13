From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/14] d80211: Fix errorcode in ieee80211_update_hw
Date: Wed, 13 Dec 2006 17:41:45 +0100 (CET)
Message-ID: <20061213164145.AE2963AA7E9@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57257 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965037AbWLMRIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:53 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

ieee80211_update_hw should return a proper error code
instead of hardcoded -1.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

cca5b9bc1f21e1d9a616e0f8e2fea04140a51a07
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 8d543f2..9e7e1b3 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4635,7 +4635,7 @@ int ieee80211_update_hw(struct ieee80211
 
 	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
 	    !hw->modes->num_channels || !hw->modes->num_rates)
-		return -1;
+		return -EINVAL;
 
 	ieee80211_precalc_modes(local);
 	local->hw.conf.phymode = hw->modes[0].mode;
-- 
1.3.0

