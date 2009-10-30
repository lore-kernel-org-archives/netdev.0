From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/4] qlge: Fix indentations.
Date: Fri, 30 Oct 2009 15:13:36 -0700
Message-ID: <1256940816-27540-5-git-send-email-ron.mercer@qlogic.com>
References: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:33628 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925AbZJ3WTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 18:19:52 -0400
In-Reply-To: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 57bbb90..224fb7c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2107,9 +2107,9 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	if (var & intr_context->irq_mask) {
 		QPRINTK_DBG(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
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

