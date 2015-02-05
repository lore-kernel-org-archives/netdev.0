From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] vxge: fix sparse warning
Date: Thu,  5 Feb 2015 13:56:09 +0000
Message-ID: <1423144569-28648-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Jon Mason <jdmason@kudzu.us>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

vxge-config.c:4640:30: warning: Using plain integer as NULL pointer

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.9.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/neterion/vxge/vxge-config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
index 2bbd01f..6223930 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -4637,7 +4637,7 @@ static void __vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
 	vpath->ringh = NULL;
 	vpath->fifoh = NULL;
 	memset(&vpath->vpath_handles, 0, sizeof(struct list_head));
-	vpath->stats_block = 0;
+	vpath->stats_block = NULL;
 	vpath->hw_stats = NULL;
 	vpath->hw_stats_sav = NULL;
 	vpath->sw_stats = NULL;
-- 
1.9.1
