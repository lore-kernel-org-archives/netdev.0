From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH v2] ath9k: mark ath_fill_led_pin() static
Date: Mon, 29 Aug 2016 20:21:13 +0800
Message-ID: <1472473273-2972-1-git-send-email-baoyou.xie@linaro.org>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33016 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933121AbcH2MVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 08:21:36 -0400
Received: by mail-pf0-f172.google.com with SMTP id y134so51686620pfg.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 05:21:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 1 warning about global functions without a declaration
in the ath9k gpio driver when building with W=1:
drivers/net/wireless/ath/ath9k/gpio.c:25:6: warning: no previous prototype for 'ath_fill_led_pin' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is declared
and don't need a declaration, but can be made static.
so this patch marks it 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/wireless/ath/ath9k/gpio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 490f74d..ddb2886 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -22,7 +22,7 @@
 
 #ifdef CONFIG_MAC80211_LEDS
 
-void ath_fill_led_pin(struct ath_softc *sc)
+static void ath_fill_led_pin(struct ath_softc *sc)
 {
 	struct ath_hw *ah = sc->sc_ah;
 
-- 
2.7.4
