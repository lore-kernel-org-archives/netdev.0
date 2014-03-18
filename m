From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 1/9] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/net/ethernet/broadcom/bnx2.c
Date: Wed, 19 Mar 2014 04:10:42 +0530
Message-ID: <1965df1cea51fc4c08e563554739fb74bbcaf58e.1395182132.git.monamagarwal123@gmail.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395182132.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395182132.git.monamagarwal123@gmail.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 965c723..5eab730 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -409,7 +409,7 @@ static int bnx2_unregister_cnic(struct net_device *dev)
 	mutex_lock(&bp->cnic_lock);
 	cp->drv_state = 0;
 	bnapi->cnic_present = 0;
-	rcu_assign_pointer(bp->cnic_ops, NULL);
+	RCU_INIT_POINTER(bp->cnic_ops, NULL);
 	mutex_unlock(&bp->cnic_lock);
 	synchronize_rcu();
 	return 0;
-- 
1.7.9.5
