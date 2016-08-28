From: Colin King <colin.king@canonical.com>
Subject: [PATCH] cxgb4/cxgb4vf: fix spelling mistake "provissioned" -> "provisioned"
Date: Sun, 28 Aug 2016 12:07:02 +0100
Message-ID: <20160828110702.10374-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_warn message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index f2951bf..100b2cc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2378,7 +2378,7 @@ static void size_nports_qsets(struct adapter *adapter)
 	 */
 	pmask_nports = hweight32(adapter->params.vfres.pmask);
 	if (pmask_nports < adapter->params.nports) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d provissioned"
+		dev_warn(adapter->pdev_dev, "only using %d of %d provisioned"
 			 " virtual interfaces; limited by Port Access Rights"
 			 " mask %#x\n", pmask_nports, adapter->params.nports,
 			 adapter->params.vfres.pmask);
-- 
2.9.3
