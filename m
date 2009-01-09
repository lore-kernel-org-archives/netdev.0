From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH] qlge: Naming interrupt vectors
Date: Fri, 09 Jan 2009 14:14:47 +0100
Message-ID: <1231506887.10395.63.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53871 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbZAINOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 08:14:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Name interrupt vectors according to the new naming standard, by Robert
Olsson and DaveM.

The qlge driver were very close to the new standard, thus the change
is kind of trivial.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index f4c0160..b7e40ad 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2746,14 +2746,14 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 				 * Outbound queue is for outbound completions only.
 				 */
 				intr_context->handler = qlge_msix_tx_isr;
-				sprintf(intr_context->name, "%s-txq-%d",
+				sprintf(intr_context->name, "%s-tx-%d",
 					qdev->ndev->name, i);
 			} else {
 				/*
 				 * Inbound queues handle unicast frames only.
 				 */
 				intr_context->handler = qlge_msix_rx_isr;
-				sprintf(intr_context->name, "%s-rxq-%d",
+				sprintf(intr_context->name, "%s-rx-%d",
 					qdev->ndev->name, i);
 			}
 		}

