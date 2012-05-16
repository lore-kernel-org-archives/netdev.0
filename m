From: pablo@netfilter.org
Subject: [PATCH 6/7] netfilter: xt_CT: remove redundant header include
Date: Thu, 17 May 2012 01:06:43 +0200
Message-ID: <1337209604-3412-7-git-send-email-pablo@netfilter.org>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39193 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932193Ab2EPXHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 19:07:30 -0400
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
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
