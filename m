From: David Miller <davem@davemloft.net>
Subject: [PATCH] irda: Kill set but unused variable 'bytes' in
 irlan_check_command_param()
Date: Thu, 19 May 2011 18:54:15 -0400 (EDT)
Message-ID: <20110519.185415.931880007743091907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab1ESWyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:54:17 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMsGhR030067
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:54:16 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/irlan/irlan_filter.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/irda/irlan/irlan_filter.c b/net/irda/irlan/irlan_filter.c
index 9ff7823..7977be7 100644
--- a/net/irda/irlan/irlan_filter.c
+++ b/net/irda/irlan/irlan_filter.c
@@ -143,12 +143,8 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
  */
 void irlan_check_command_param(struct irlan_cb *self, char *param, char *value)
 {
-	__u8 *bytes;
-
 	IRDA_DEBUG(4, "%s()\n", __func__ );
 
-	bytes = value;
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-- 
1.7.4.4

