From: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2] fix:brcmfmac: add missing header dependencies
Date: Sat, 27 Aug 2016 14:08:23 +0800
Message-ID: <1472278103-28320-1-git-send-email-baoyou.xie@linaro.org>
Cc: baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        xie.baoyou-Th6q7B73Y6EnDS1+zs4M5A@public.gmane.org
To: franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We get 1 warning when biuld kernel with W=1:
drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6: warning: no previous prototype for '__brcmf_err' [-Wmissing-
prototypes]

In fact, this function is declared in brcmfmac/debug.h, so this patch
add missing header dependencies

Signed-off-by: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
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
