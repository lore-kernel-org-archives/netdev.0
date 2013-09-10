From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: ath9k: Use NULL instead of false
Date: Tue, 10 Sep 2013 11:50:36 +0530
Message-ID: <1378794036-13630-1-git-send-email-sachin.kamat@linaro.org>
Cc: ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	mcgrof@qca.qualcomm.com, jouni@qca.qualcomm.com,
	vthiagar@qca.qualcomm.com, senthilb@qca.qualcomm.com,
	linville@tuxdriver.com, sachin.kamat@linaro.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:39848 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab3IJGik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 02:38:40 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so7144491pbb.41
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 23:38:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function returns a pointer. Hence return NULL instead of false.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/dfs_pri_detector.c b/drivers/net/wireless/ath/ath9k/dfs_pri_detector.c
index 5ba4b6f..c718fc3 100644
--- a/drivers/net/wireless/ath/ath9k/dfs_pri_detector.c
+++ b/drivers/net/wireless/ath/ath9k/dfs_pri_detector.c
@@ -392,7 +392,7 @@ static struct pri_sequence *pri_detector_add_pulse(struct pri_detector *de,
 
 	if (!pseq_handler_create_sequences(de, ts, max_updated_seq)) {
 		pri_detector_reset(de, ts);
-		return false;
+		return NULL;
 	}
 
 	ps = pseq_handler_check_detection(de);
-- 
1.7.9.5
