From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] ath5k: drop duplicate header vmalloc.h
Date: Thu, 24 Nov 2016 21:58:28 +0800
Message-ID: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>,
        Nick Kossifidis <mickflemm@gmail.com>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop duplicate header vmalloc.h from ath5k/debug.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/wireless/ath/ath5k/debug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath5k/debug.c b/drivers/net/wireless/ath/ath5k/debug.c
index 4f8d9ed..d068df5 100644
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@ -66,7 +66,6 @@
 
 #include <linux/seq_file.h>
 #include <linux/list.h>
-#include <linux/vmalloc.h>
 #include "debug.h"
 #include "ath5k.h"
 #include "reg.h"
-- 
2.9.3
