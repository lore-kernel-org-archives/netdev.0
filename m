From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: enable GRO by default
Date: Wed, 15 Sep 2010 20:22:17 -0700
Message-ID: <20100915202217.365fee46@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50478 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694Ab0IPDWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 23:22:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver has supported GRO for a while, but it was not enabled
by default.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-09-15 18:09:55.656753541 -0700
+++ b/drivers/net/sky2.c	2010-09-15 18:13:50.953918039 -0700
@@ -4581,7 +4581,8 @@ static __devinit struct net_device *sky2
 
 	sky2->port = port;
 
-	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG;
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG
+		| NETIF_F_TSO  | NETIF_F_GRO;
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
 
