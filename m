From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] rtlwifi: rtl8723be: Remove duplicate inclusion of phy.h
Date: Thu, 29 May 2014 16:39:23 +0530
Message-ID: <1401361764-9050-1-git-send-email-sachin.kamat@linaro.org>
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com, sachin.kamat@linaro.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:39712 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756410AbaE2LLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 07:11:48 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so197305pbb.41
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 04:11:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy.h was included twice.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index e0a0d8c8fed5..969eaea5eddd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -33,7 +33,6 @@
 #include "trx.h"
 #include "led.h"
 #include "dm.h"
-#include "phy.h"
 
 static u8 _rtl8723be_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 {
-- 
1.7.9.5
