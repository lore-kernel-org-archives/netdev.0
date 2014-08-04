From: Hans Wennborg <hans@hanshq.net>
Subject: [PATCH 09/19] net: smc911x: fix %d confusingly prefixed with 0x in format string
Date: Sun,  3 Aug 2014 17:19:46 -0700
Message-ID: <1407111586-14903-1-git-send-email-hans@hanshq.net>
Cc: Hans Wennborg <hans@hanshq.net>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hans Wennborg <hans@hanshq.net>
---
 drivers/net/ethernet/smsc/smc911x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 1c44e67..9778cba 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -730,7 +730,7 @@ static void smc911x_phy_detect(struct net_device *dev)
 			lp->phy_type = id1 << 16 | id2;
 	}
 
-	DBG(SMC_DEBUG_MISC, dev, "phy_id1=0x%x, phy_id2=0x%x phyaddr=0x%d\n",
+	DBG(SMC_DEBUG_MISC, dev, "phy_id1=0x%x, phy_id2=0x%x phyaddr=0x%x\n",
 	    id1, id2, lp->mii.phy_id);
 }
 
-- 
2.0.0.526.g5318336
