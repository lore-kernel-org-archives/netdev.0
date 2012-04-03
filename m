From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] vxge: Remove unnecessary ; in do {} while (0) macro
Date: Tue, 03 Apr 2012 14:53:12 -0700
Message-ID: <1333489992.2695.17.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This macro doesn't need a terminating ; so just remove it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.h b/drivers/net/ethernet/neterion/vxge/vxge-main.h
index f52a42d..372406c 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.h
@@ -421,7 +421,7 @@ struct vxge_tx_priv {
 		timer.function = handle; \
 		timer.data = (unsigned long) arg; \
 		mod_timer(&timer, (jiffies + exp)); \
-	} while (0);
+	} while (0)
 
 void vxge_initialize_ethtool_ops(struct net_device *ndev);
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
