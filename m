From: David Miller <davem@davemloft.net>
Subject: [PATCH] irda: Kill set but unused variable 'clen' in
 ircomm_connect_indication()
Date: Thu, 19 May 2011 18:53:17 -0400 (EDT)
Message-ID: <20110519.185317.2153276354104624268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab1ESWxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:53:19 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMrHj4029994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:53:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/ircomm/ircomm_core.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index e970820..52079f1 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -244,14 +244,8 @@ EXPORT_SYMBOL(ircomm_connect_request);
 void ircomm_connect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 			       struct ircomm_info *info)
 {
-	int clen = 0;
-
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
-	/* Check if the packet contains data on the control channel */
-	if (skb->len > 0)
-		clen = skb->data[0];
-
 	/*
 	 * If there are any data hiding in the control channel, we must
 	 * deliver it first. The side effect is that the control channel
-- 
1.7.4.4

