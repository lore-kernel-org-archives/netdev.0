From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: fix tx ring size in ethtool -g
Date: Thu, 16 Apr 2009 14:28:37 +0200
Message-ID: <49E72475.5050706@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1919 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756284AbZDPM2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 08:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix tx ring size reported via ethtool -g.

Signed-off-by; Brice Goglin <brice@myri.com>

--- linux-tmp.old/drivers/net/myri10ge/myri10ge.c    2009-04-09
14:00:16.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c    2009-04-10
23:11:59.000000000 +0200
@@ -1696,7 +1696,7 @@
     ring->rx_mini_max_pending = mgp->ss[0].rx_small.mask + 1;
     ring->rx_max_pending = mgp->ss[0].rx_big.mask + 1;
     ring->rx_jumbo_max_pending = 0;
-    ring->tx_max_pending = mgp->ss[0].rx_small.mask + 1;
+    ring->tx_max_pending = mgp->ss[0].tx.mask + 1;
     ring->rx_mini_pending = ring->rx_mini_max_pending;
     ring->rx_pending = ring->rx_max_pending;
     ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;

