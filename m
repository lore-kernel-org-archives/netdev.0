From: David Miller <davem@davemloft.net>
Subject: [PATCH] irda: Kill set but unused vars 'saddr' and 'daddr' in
 irlan_provider_connect_indication()
Date: Thu, 19 May 2011 18:47:01 -0400 (EDT)
Message-ID: <20110519.184701.1723992435491479138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab1ESWrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:47:03 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMl1rX029378
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:47:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/irlan/irlan_provider.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 5cf5e6c..b8af74a 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -128,7 +128,6 @@ static void irlan_provider_connect_indication(void *instance, void *sap,
 {
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
-	__u32 saddr, daddr;
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
@@ -141,8 +140,6 @@ static void irlan_provider_connect_indication(void *instance, void *sap,
 	IRDA_ASSERT(tsap == self->provider.tsap_ctrl,return;);
 	IRDA_ASSERT(self->provider.state == IRLAN_IDLE, return;);
 
-	daddr = irttp_get_daddr(tsap);
-	saddr = irttp_get_saddr(tsap);
 	self->provider.max_sdu_size = max_sdu_size;
 	self->provider.max_header_size = max_header_size;
 
-- 
1.7.4.4

