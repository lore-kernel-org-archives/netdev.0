From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] qlge: Convert /n to \n
Date: Thu, 24 Apr 2014 18:50:59 -0700
Message-ID: <0cfcf37f20b78a2bc3cde9f56aa27ca53a802184.1398390579.git.joe@perches.com>
References: <cover.1398390579.git.joe@perches.com>
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1398390579.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a newline character appropriately.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 0a1d76a..6e36fe1 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -3595,7 +3595,7 @@ static int ql_request_irq(struct ql_adapter *qdev)
 	}
 	return status;
 err_irq:
-	netif_err(qdev, ifup, qdev->ndev, "Failed to get the interrupts!!!/n");
+	netif_err(qdev, ifup, qdev->ndev, "Failed to get the interrupts!!!\n");
 	ql_free_irq(qdev);
 	return status;
 }
-- 
1.8.1.2.459.gbcd45b4.dirty
