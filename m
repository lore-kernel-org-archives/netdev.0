From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 05/15] net: wireless: ti: Return flow can be simplified for wl1271_cmd_interrogate
Date: Wed, 21 Oct 2015 20:25:27 +0530
Message-ID: <1445439337-19055-6-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the wlcore/acx.c file that fixes up warning
reported by coccicheck:

WARNING: end returns can be simplified if negative or 0 value

Prefer direct return value instead of writing 2-3 more sentence.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ti/wlcore/acx.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index f28fa3b..331382c 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -162,12 +162,8 @@ int wl1271_acx_mem_map(struct wl1271 *wl, struct acx_header *mem_map,
 
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
