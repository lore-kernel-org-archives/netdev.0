From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/7] qlcnic: fix rx bytes statistics
Date: Mon, 17 May 2010 04:22:10 -0700
Message-ID: <1274095334-32362-4-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:28330 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751894Ab0EQKVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:50 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Added lrobytes to it.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index db05635..0a52d24 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1702,7 +1702,7 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 
 	stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
 	stats->tx_packets = adapter->stats.xmitfinished;
-	stats->rx_bytes = adapter->stats.rxbytes;
+	stats->rx_bytes = adapter->stats.rxbytes + adapter->stats.lrobytes;
 	stats->tx_bytes = adapter->stats.txbytes;
 	stats->rx_dropped = adapter->stats.rxdropped;
 	stats->tx_dropped = adapter->stats.txdropped;
-- 
1.5.6.1

