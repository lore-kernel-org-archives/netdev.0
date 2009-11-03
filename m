From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Fix indentations.
Date: Tue,  3 Nov 2009 15:49:29 -0800
Message-ID: <1257292171-11683-2-git-send-email-ron.mercer@qlogic.com>
References: <1257292171-11683-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:59731 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbZKCXzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 18:55:50 -0500
In-Reply-To: <1257292171-11683-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fa53009..4a07548 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2102,12 +2102,12 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	var = ql_read32(qdev, ISR1);
 	if (var & intr_context->irq_mask) {
-				QPRINTK(qdev, INTR, INFO,
+		QPRINTK(qdev, INTR, INFO,
 			"Waking handler for rx_ring[0].\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
-					napi_schedule(&rx_ring->napi);
-				work_done++;
-			}
+		napi_schedule(&rx_ring->napi);
+		work_done++;
+	}
 	ql_enable_completion_interrupt(qdev, intr_context->intr);
 	return work_done ? IRQ_HANDLED : IRQ_NONE;
 }
-- 
1.6.0.2

