From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] blackfin_mac: unneeded assignment
Date: Fri, 25 Jul 2008 11:46:46 -0700
Message-ID: <20080725114646.35f99145@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cooloney@kernel.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50177 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbYGYSqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 14:46:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is set by eth_type_trans already.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bfin_mac.c	2008-07-25 10:19:53.000000000 -0700
+++ b/drivers/net/bfin_mac.c	2008-07-25 10:20:53.000000000 -0700
@@ -691,7 +691,6 @@ static void bfin_mac_rx(struct net_devic
 					 (unsigned long)skb->tail);
 
 	dev->last_rx = jiffies;
-	skb->dev = dev;
 	skb->protocol = eth_type_trans(skb, dev);
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
