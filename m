From: kaber@trash.net
Subject: [PATCH 62/84] netfilter: fix some coding styles and remove moduleparam.h
Date: Mon, 10 May 2010 22:18:33 +0200
Message-ID: <1273522735-24672-63-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756902Ab0EJUTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:20 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

Fix some coding styles and remove moduleparam.h

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_standalone.c |    3 +--
 net/ipv4/netfilter/nf_nat_tftp.c       |    1 -
 net/netfilter/nf_conntrack_proto.c     |    2 --
 3 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 5678e95..0b49248 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -137,9 +137,8 @@ nf_nat_fn(unsigned int hooknum,
 				ret = nf_nat_rule_find(skb, hooknum, in, out,
 						       ct);
 
-			if (ret != NF_ACCEPT) {
+			if (ret != NF_ACCEPT)
 				return ret;
-			}
 		} else
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == IP_NAT_MANIP_SRC ? "SRC" : "DST",
diff --git a/net/ipv4/netfilter/nf_nat_tftp.c b/net/ipv4/netfilter/nf_nat_tftp.c
index b096e81..7274a43 100644
--- a/net/ipv4/netfilter/nf_nat_tftp.c
+++ b/net/ipv4/netfilter/nf_nat_tftp.c
@@ -6,7 +6,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/udp.h>
 
 #include <net/netfilter/nf_nat_helper.h>
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 1a4568b..f71cd5d 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -13,12 +13,10 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
-#include <linux/skbuff.h>
 #include <linux/vmalloc.h>
 #include <linux/stddef.h>
 #include <linux/err.h>
 #include <linux/percpu.h>
-#include <linux/moduleparam.h>
 #include <linux/notifier.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-- 
1.7.0.4

