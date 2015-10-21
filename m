From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH v2 05/15] net: wireless: ti: Return flow can be simplified for wl1271_cmd_interrogate
Date: Thu, 22 Oct 2015 00:37:07 +0530
Message-ID: <1445454428-12331-1-git-send-email-punitvara@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jslaby@suse.cz, lkp@intel.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove int ret suggested by kbuild test robot

This patch is to the wlcore/acx.c file that fixes up warning
reported by coccicheck:

WARNING: end returns can be simplified if negative or 0 value

Prefer direct return value instead of writing 2-3 more sentence.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ti/wlcore/acx.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index f28fa3b..6b566d9 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -158,16 +158,11 @@ out:
 int wl1271_acx_mem_map(struct wl1271 *wl, struct acx_header *mem_map,
 		       size_t len)
 {
-	int ret;
 
 	wl1271_debug(DEBUG_ACX, "acx mem map");
 
-	ret = wl1271_cmd_interrogate(wl, ACX_MEM_MAP, mem_map,
+	return wl1271_cmd_interrogate(wl, ACX_MEM_MAP, mem_map,
 				     sizeof(struct acx_header), len);
-	if (ret < 0)
-		return ret;
-
-	return 0;
 }
 
 int wl1271_acx_rx_msdu_life_time(struct wl1271 *wl)
-- 
2.5.3
