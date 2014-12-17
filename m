From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 04/10] loopback: Turn on UFO6 support.
Date: Wed, 17 Dec 2014 13:20:49 -0500
Message-ID: <1418840455-22598-5-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:51007 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaLQSVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:21 -0500
Received: by mail-qa0-f49.google.com with SMTP id s7so11506672qap.36
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:21 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn on UFO6 support.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/loopback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c76283c..762c28a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -170,10 +170,10 @@ static void loopback_setup(struct net_device *dev)
 	dev->flags		= IFF_LOOPBACK;
 	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
 	netif_keep_dst(dev);
-	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
+	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_ALL_UFO;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
 		| NETIF_F_ALL_TSO
-		| NETIF_F_UFO
+		| NETIF_F_ALL_UFO
 		| NETIF_F_HW_CSUM
 		| NETIF_F_RXCSUM
 		| NETIF_F_SCTP_CSUM
-- 
1.9.3
