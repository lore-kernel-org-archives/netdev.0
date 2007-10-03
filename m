From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] baycom epp header ops
Date: Tue, 2 Oct 2007 17:41:03 -0700
Message-ID: <20071002174103.4303b9dc@oldman>
References: <200710022104.l92L4cuE022227@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35020 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbXJCAkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 20:40:20 -0400
In-Reply-To: <200710022104.l92L4cuE022227@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update baycom epp driver for new header ops in net-2.6.24

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/hamradio/baycom_epp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 355c6cf..1a5a75a 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1159,8 +1159,7 @@ static void baycom_probe(struct net_device *dev)
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;
 	
-	dev->hard_header = ax25_hard_header;
-	dev->rebuild_header = ax25_rebuild_header;
+	dev->header_ops = &ax25_header_ops;
 	dev->set_mac_address = baycom_set_mac_address;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
-- 
1.5.2.5

