From: Maninder Singh <maninder1.s@samsung.com>
Subject: [RESUBMIT Patch 1/1] net: replace if()/BUG with BUG_ON
Date: Wed, 17 Jun 2015 10:06:01 +0530
Message-ID: <1434515761-14796-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: davem@davemloft.net, willemb@google.com, dborkman@redhat.com,
	al.drozdov@gmail.com, viro@zeniv.linux.org.uk,
	eyal.birger@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:47688 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbbFQEg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 00:36:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BUG_ON(condition) instead of if(condition)/BUG() .

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>
---
 net/packet/af_packet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5989c6..c91d405 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -547,8 +547,7 @@ static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
 {
 	struct tpacket_kbdq_core *pkc;
 
-	if (tx_ring)
-		BUG();
+	BUG_ON(tx_ring);
 
 	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
 			GET_PBDQC_FROM_RB(&po->rx_ring);
-- 
1.7.1
