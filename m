From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/42] atl1e: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:33:07 -0700 (PDT)
Message-ID: <20110417.173307.246534707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753824Ab1DRAdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:41 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5D03824C08A
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'tx_ring' is set but unused in
atl1e_init_ring_resources().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/atl1e/atl1e_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 9900ca1..86a9122 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -691,10 +691,8 @@ static void atl1e_cal_ring_size(struct atl1e_adapter *adapter, u32 *ring_size)
 
 static void atl1e_init_ring_resources(struct atl1e_adapter *adapter)
 {
-	struct atl1e_tx_ring *tx_ring = NULL;
 	struct atl1e_rx_ring *rx_ring = NULL;
 
-	tx_ring = &adapter->tx_ring;
 	rx_ring = &adapter->rx_ring;
 
 	rx_ring->real_page_size = adapter->rx_ring.page_size
-- 
1.7.4.3

