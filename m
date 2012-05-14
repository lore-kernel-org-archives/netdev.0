From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: xt_CT: remove redundant header include
Date: Mon, 14 May 2012 13:47:02 +0200
Message-ID: <1336996023-20249-4-git-send-email-pablo@netfilter.org>
References: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35183 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756163Ab2ENLrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 07:47:32 -0400
In-Reply-To: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eldad Zack <eldad@fogrefinery.com>

nf_conntrack_l4proto.h is included twice.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 3746d8b..a51de9b 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -17,7 +17,6 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
-#include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_timeout.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
-- 
1.7.10
