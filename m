From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: change mdelay to msleep
Date: Fri, 22 Mar 2013 11:57:55 -0400
Message-ID: <1363967877-16812-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27813 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933876Ab3CVQVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:21:14 -0400
In-Reply-To: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index a69097c..6428a14 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -655,7 +655,7 @@ void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 				qlcnic_83xx_config_intrpt(adapter, 0);
 		}
 		/* Allow dma queues to drain after context reset */
-		mdelay(20);
+		msleep(20);
 	}
 }
 
-- 
1.5.6
