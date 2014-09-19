From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: fix code identation
Date: Fri, 19 Sep 2014 14:26:03 +0800
Message-ID: <1411107963-8303-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <dan.carpenter@oracle.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0134.outbound.protection.outlook.com ([207.46.100.134]:25838
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751464AbaISGwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 02:52:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There have extra identation before .skb_copy_to_linear_data_offset(),
this patch just remove the identation.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6e93336..bf3fd15 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1415,7 +1415,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 			skb_copy_to_linear_data(skb, data, (2 * ETH_ALEN));
 			if (vlan_packet_rcvd)
 				payload_offset = (2 * ETH_ALEN) + VLAN_HLEN;
-				skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
+			skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
 						       data + payload_offset,
 						       pkt_len - 4 - (2 * ETH_ALEN));
 
-- 
1.7.8
