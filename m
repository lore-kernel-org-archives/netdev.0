From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/2] rtlwifi: rtl8723ae: Remove duplicate inclusion of fw_common.h
Date: Thu, 29 May 2014 16:39:24 +0530
Message-ID: <1401361764-9050-2-git-send-email-sachin.kamat@linaro.org>
References: <1401361764-9050-1-git-send-email-sachin.kamat@linaro.org>
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com, sachin.kamat@linaro.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:36092 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140AbaE2LLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 07:11:51 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so209166pbc.1
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 04:11:51 -0700 (PDT)
In-Reply-To: <1401361764-9050-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fw_common.h was included twice.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
index 48fee1be78c2..5b4a714f3c8c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
@@ -32,7 +32,6 @@
 #include "dm.h"
 #include "fw.h"
 #include "../rtl8723com/fw_common.h"
-#include "../rtl8723com/fw_common.h"
 #include "phy.h"
 #include "reg.h"
 #include "hal_btc.h"
-- 
1.7.9.5
