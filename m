From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH] ath6kl: fix compilation warning in ath6kl_htc_pipe_conn_service
Date: Sun, 29 Sep 2013 15:54:31 +0200
Message-ID: <1380462871-2649-1-git-send-email-murzin.v@gmail.com>
Cc: kvalo@qca.qualcomm.com, linville@tuxdriver.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:52934 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab3I2NzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 09:55:16 -0400
Received: by mail-la0-f49.google.com with SMTP id ev20so3568738lab.22
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 06:55:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the warning

drivers/net/wireless/ath/ath6kl/htc_pipe.c: In function
'ath6kl_htc_pipe_conn_service':
drivers/net/wireless/ath/ath6kl/htc_pipe.c:1293:26: warning: integer overflow
in expression [-Woverflow]

by giving a hint to compiler about unsigned nature of
HTC_CONN_FLGS_SET_RECV_ALLOC_MASK

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---
 drivers/net/wireless/ath/ath6kl/htc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/htc.h b/drivers/net/wireless/ath/ath6kl/htc.h
index a2c8ff8..14cab14 100644
--- a/drivers/net/wireless/ath/ath6kl/htc.h
+++ b/drivers/net/wireless/ath/ath6kl/htc.h
@@ -60,7 +60,7 @@
 /* disable credit flow control on a specific service */
 #define HTC_CONN_FLGS_DISABLE_CRED_FLOW_CTRL          (1 << 3)
 #define HTC_CONN_FLGS_SET_RECV_ALLOC_SHIFT    8
-#define HTC_CONN_FLGS_SET_RECV_ALLOC_MASK     0xFF00
+#define HTC_CONN_FLGS_SET_RECV_ALLOC_MASK     0xFF00U
 
 /* connect response status codes */
 #define HTC_SERVICE_SUCCESS      0
-- 
1.8.1.5
