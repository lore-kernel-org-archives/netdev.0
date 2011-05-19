From: David Miller <davem@davemloft.net>
Subject: [PATCH] 9p: Kill unused variable 'ret' in trans_rdma.c:parse_opts()
Date: Thu, 19 May 2011 17:45:51 -0400 (EDT)
Message-ID: <20110519.174551.1931401130169865650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934827Ab1ESVpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 17:45:52 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JLjpIk022815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 14:45:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Probably just cut and pasted from the other parse_opts() implementations
in the 9p sources.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/9p/trans_rdma.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 150e0c4..844a7a5 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -167,7 +167,6 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 	substring_t args[MAX_OPT_ARGS];
 	int option;
 	char *options, *tmp_options;
-	int ret;
 
 	opts->port = P9_PORT;
 	opts->sq_depth = P9_RDMA_SQ_DEPTH;
@@ -195,7 +194,6 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 		if (r < 0) {
 			P9_DPRINTK(P9_DEBUG_ERROR,
 				   "integer field, but no integer?\n");
-			ret = r;
 			continue;
 		}
 		switch (token) {
-- 
1.7.4.4

