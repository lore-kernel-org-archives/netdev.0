From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 07/15] wcn36xx: Fetch private sta data from sta entry instead of from vif
Date: Sun,  3 Apr 2016 15:16:38 -0700
Message-ID: <1459721806-11817-7-git-send-email-bjorn.andersson@linaro.org>
References: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>, wcn36xx@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34918 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbcDCWQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 18:16:57 -0400
Received: by mail-pf0-f174.google.com with SMTP id n1so25355135pfn.2
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 15:16:56 -0700 (PDT)
In-Reply-To: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pontus Fuchs <pontus.fuchs@gmail.com>

For consistency with other code.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 30f015d3a9e6..a23738deb5b3 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -386,7 +386,7 @@ static int wcn36xx_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 {
 	struct wcn36xx *wcn = hw->priv;
 	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
-	struct wcn36xx_sta *sta_priv = vif_priv->sta;
+	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
 	int ret = 0;
 	u8 key[WLAN_MAX_KEY_LEN];
 
-- 
2.5.0
