From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 16/16] wcn36xx: Use correct command struct for EXIT_BMPS_REQ
Date: Mon, 28 Mar 2016 23:06:33 -0700
Message-ID: <1459231593-360-17-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pontus Fuchs <pontus.fuchs@gmail.com>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36228 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756020AbcC2GG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 02:06:56 -0400
Received: by mail-pf0-f173.google.com with SMTP id u190so6578366pfb.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 23:06:56 -0700 (PDT)
In-Reply-To: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pontus Fuchs <pontus.fuchs@gmail.com>

EXIT_BMPS_REQ was using the command struct for ENTER_BMPS_REQ. I
spotted this when looking at command dumps.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index b1bdc229e560..c15501c06eb2 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1690,7 +1690,7 @@ out:
 
 int wcn36xx_smd_exit_bmps(struct wcn36xx *wcn, struct ieee80211_vif *vif)
 {
-	struct wcn36xx_hal_enter_bmps_req_msg msg_body;
+	struct wcn36xx_hal_exit_bmps_req_msg msg_body;
 	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
-- 
2.5.0
