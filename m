From: David Miller <davem@davemloft.net>
Subject: [PATCH] 9p: Kill set but not used variable 'ret' in parse_opts()
Date: Thu, 19 May 2011 17:39:48 -0400 (EDT)
Message-ID: <20110519.173948.743702337928915872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934614Ab1ESVju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 17:39:50 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JLdmn3022129
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 14:39:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/9p/trans_fd.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index aa5672b..4a90843 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -716,7 +716,6 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 	substring_t args[MAX_OPT_ARGS];
 	int option;
 	char *options, *tmp_options;
-	int ret;
 
 	opts->port = P9_PORT;
 	opts->rfd = ~0;
@@ -744,7 +743,6 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 			if (r < 0) {
 				P9_DPRINTK(P9_DEBUG_ERROR,
 				"integer field, but no integer?\n");
-				ret = r;
 				continue;
 			}
 		}
-- 
1.7.4.4

