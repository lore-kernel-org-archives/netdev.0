From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH] netxen: Fix Unlikely(x) > y
Date: Tue, 6 Oct 2009 22:34:39 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B6A7C12@AVEXMB1.qlogic.org>
References: <4ACB44DA.1010300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Roel Kluin <roel.kluin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:43954 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755211AbZJGFfX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 01:35:23 -0400
In-Reply-To: <4ACB44DA.1010300@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh sure, that was a typo. Thanks for catching it. 

Acked-by: Dhananjay Phadke <dhananjay@netxen.com>

-----Original Message-----
From: Roel Kluin [mailto:roel.kluin@gmail.com] 
Sent: Tuesday, October 06, 2009 06:24
To: Dhananjay Phadke; netdev@vger.kernel.org; Andrew Morton
Subject: [PATCH] netxen: Fix Unlikely(x) > y

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
