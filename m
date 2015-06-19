From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/12] net: include missing headers in net/net_namespace.h
Date: Fri, 19 Jun 2015 19:17:45 +0200
Message-ID: <1434734269-4545-9-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55543 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754649AbbFSRMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 13:12:37 -0400
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include linux/idr.h and linux/skbuff.h since they are required by objects that
are declared in the net structure.

 struct net {
	...
	struct idr		netns_ids;
	...
	struct sk_buff_head	wext_nlevents;
	...

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 72eb237..e951453 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -28,6 +28,8 @@
 #include <net/netns/xfrm.h>
 #include <net/netns/mpls.h>
 #include <linux/ns_common.h>
+#include <linux/idr.h>
+#include <linux/skbuff.h>
 
 struct user_namespace;
 struct proc_dir_entry;
-- 
1.7.10.4
