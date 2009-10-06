From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] netxen: Fix Unlikely(x) > y
Date: Tue, 06 Oct 2009 15:23:38 +0200
Message-ID: <4ACB44DA.1010300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Dhananjay Phadke <dhananjay@netxen.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:36899 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433AbZJFNPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 09:15:34 -0400
Received: by ewy17 with SMTP id 17so3875684ewy.39
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2009 06:14:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The closing parenthesis was not on the right location.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
This was intended, I think?

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b5aa974..9b9eab1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1714,7 +1714,7 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
 
-	if (unlikely(no_of_desc + 2) > netxen_tx_avail(tx_ring)) {
+	if (unlikely(no_of_desc + 2 > netxen_tx_avail(tx_ring))) {
 		netif_stop_queue(netdev);
 		return NETDEV_TX_BUSY;
 	}
