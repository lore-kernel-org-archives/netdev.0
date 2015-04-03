From: greearb@candelatech.com
Subject: [PATCH 2/4] mac80211-hwsim: remove dmesg spam about get-survey.
Date: Fri,  3 Apr 2015 14:12:01 -0700
Message-ID: <1428095523-374-2-git-send-email-greearb@candelatech.com>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Cc: johannes@sipsolutions.net, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34588 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbDCVMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 17:12:07 -0400
In-Reply-To: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This message just fills up dmesg and/or kernel logs and does
not provide any useful information.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index d0e88b2..5089169 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1696,7 +1696,7 @@ static int mac80211_hwsim_get_survey(
 {
 	struct ieee80211_conf *conf = &hw->conf;
 
-	wiphy_debug(hw->wiphy, "%s (idx=%d)\n", __func__, idx);
+	/* wiphy_debug(hw->wiphy, "%s (idx=%d)\n", __func__, idx); */
 
 	if (idx != 0)
 		return -ENOENT;
-- 
1.7.11.7
