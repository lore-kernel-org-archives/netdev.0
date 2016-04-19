From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v3 11/18] wcn36xx: Use allocated self sta index instead of hard coded
Date: Mon, 18 Apr 2016 22:00:49 -0700
Message-ID: <1461042056-10607-12-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34302 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbcDSFBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 01:01:12 -0400
Received: by mail-pa0-f50.google.com with SMTP id r5so2446188pag.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 22:01:12 -0700 (PDT)
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pontus Fuchs <pontus.fuchs@gmail.com>

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index ebb446272d21..e0d5631657c1 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -200,7 +200,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 		sta_params->sta_index = WCN36XX_HAL_STA_INVALID_IDX;
 	} else {
 		sta_params->type = 0;
-		sta_params->sta_index = 1;
+		sta_params->sta_index = vif_priv->self_sta_index;
 	}
 
 	sta_params->listen_interval = WCN36XX_LISTEN_INTERVAL(wcn);
-- 
2.5.0
