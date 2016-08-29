From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH v3] brcmfmac: add missing header dependencies
Date: Mon, 29 Aug 2016 16:14:45 +0800
Message-ID: <1472458485-24499-1-git-send-email-baoyou.xie@linaro.org>
Cc: baoyou.xie@linaro.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@linaro.org,
        xie.baoyou@zte.com.cn
To: franky.lin@broadcom.com, hante.meuleman@broadcom.com,
        kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when biuld kernel with W=1:
drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6: warning: no previous prototype for '__brcmf_err' [-Wmissing-prototypes]

In fact, this function is declared in brcmfmac/debug.h, so this patch
add missing header dependencies.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
index a10f35c..fe67559 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
@@ -19,6 +19,7 @@
 #ifndef __CHECKER__
 #define CREATE_TRACE_POINTS
 #include "tracepoint.h"
+#include "debug.h"
 
 void __brcmf_err(const char *func, const char *fmt, ...)
 {
-- 
2.7.4
