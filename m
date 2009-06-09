From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/8] qlge: Remove netif_set_gso_max_size() call.
Date: Tue,  9 Jun 2009 08:39:30 -0700
Message-ID: <1244561974-25662-4-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbZFIPrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:15 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not necessary if hardware supports 65536 as it's the default setting.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index f2e4501..738691d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3382,7 +3382,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * completion handler rx_rings.
 	 */
 	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
-	netif_set_gso_max_size(qdev->ndev, 65536);
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
-- 
1.6.0.2

