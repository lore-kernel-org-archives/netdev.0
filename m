From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: remove unnecessary null test before debugfs_remove_recursive
Date: Fri, 27 Jun 2014 22:51:52 +0200
Message-ID: <1403902312-10930-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch warning:
"WARNING: debugfs_remove_recursive(NULL) is safe this check is probably not required"

Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a83271c..3781b9e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6366,8 +6366,7 @@ static void remove_one(struct pci_dev *pdev)
 			if (adapter->port[i]->reg_state == NETREG_REGISTERED)
 				unregister_netdev(adapter->port[i]);
 
-		if (adapter->debugfs_root)
-			debugfs_remove_recursive(adapter->debugfs_root);
+		debugfs_remove_recursive(adapter->debugfs_root);
 
 		/* If we allocated filters, free up state associated with any
 		 * valid filters ...
-- 
1.8.4.5
