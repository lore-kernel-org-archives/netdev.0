From: David Miller <davem@davemloft.net>
Subject: [PATCH] rose: Delete commented out references to ancient
 firewalling code.
Date: Thu, 07 Jul 2011 02:42:28 -0700 (PDT)
Message-ID: <20110707.024228.289834005545134231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab1GGJmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 05:42:31 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p679gSi6002951
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2011 02:42:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These intefaces haven't existed since 2.2.x

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rose/rose_link.c  |    7 -------
 net/rose/rose_route.c |    5 -----
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index fa5f564..7a02bd1 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -266,13 +266,6 @@ void rose_transmit_link(struct sk_buff *skb, struct rose_neigh *neigh)
 {
 	unsigned char *dptr;
 
-#if 0
-	if (call_fw_firewall(PF_ROSE, skb->dev, skb->data, NULL, &skb) != FW_ACCEPT) {
-		kfree_skb(skb);
-		return;
-	}
-#endif
-
 	if (neigh->loopback) {
 		rose_loopback_queue(skb, neigh);
 		return;
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 479cae5..d389de1 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -864,11 +864,6 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 	int res = 0;
 	char buf[11];
 
-#if 0
-	if (call_in_firewall(PF_ROSE, skb->dev, skb->data, NULL, &skb) != FW_ACCEPT)
-		return res;
-#endif
-
 	if (skb->len < ROSE_MIN_LEN)
 		return res;
 	frametype = skb->data[2];
-- 
1.7.6

