From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] vmxnet3: convert BUG_ON(true) into a simple BUG()
Date: Thu,  8 Nov 2012 15:23:03 -0500
Message-ID: <1352406191-14303-1-git-send-email-sasha.levin@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 0ae1bcc..7e9622f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1922,7 +1922,7 @@ vmxnet3_free_irqs(struct vmxnet3_adapter *adapter)
 		free_irq(adapter->pdev->irq, adapter->netdev);
 		break;
 	default:
-		BUG_ON(true);
+		BUG();
 	}
 }
 
-- 
1.7.10.4
