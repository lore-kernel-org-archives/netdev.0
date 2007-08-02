From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] TIPC: make function tipc_nameseq_subscribe static
Date: Fri, 3 Aug 2007 00:56:38 +0200
Message-ID: <20070802225638.GA14966@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:36856 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750913AbXHBW4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 18:56:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make needlessly global function tipc_nameseq_subscribe static.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index d8473ee..ac7dfdd 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -501,7 +501,7 @@ end_node:
  * sequence overlapping with the requested sequence
  */
 
-void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s)
+static void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s)
 {
 	struct sub_seq *sseq = nseq->sseqs;
 

