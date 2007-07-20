From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 1/10] ps3: fix wrong calculation of rx descriptor address
Date: Fri, 20 Jul 2007 17:20:54 +0900
Message-ID: <20070720172015.6787.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:58182 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762718AbXGTIU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:20:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed the bug that calculation of the address of rx descriptor was
wrong.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1107,7 +1107,7 @@ static int gelic_net_open(struct net_dev
 			card->descr, GELIC_NET_TX_DESCRIPTORS))
 		goto alloc_tx_failed;
 	if (gelic_net_init_chain(card, &card->rx_chain,
-				 card->descr + GELIC_NET_RX_DESCRIPTORS,
+				 card->descr + GELIC_NET_TX_DESCRIPTORS,
 				 GELIC_NET_RX_DESCRIPTORS))
 		goto alloc_rx_failed;
 

--
Masakazu MOKUNO

