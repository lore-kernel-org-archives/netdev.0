From: pablo@netfilter.org
Subject: [PATCH 13/23] netfilter: remove ipt_SAME.h and ipt_realm.h
Date: Thu,  8 Mar 2012 02:01:02 +0100
Message-ID: <1331168472-5820-14-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WANG Cong <xiyou.wangcong@gmail.com>

These two headers are not required anymore, they have been
replaced by xt_SAME.h and xt_realm.h.

Florian Westphal pointed out this.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_ipv4/Kbuild      |    2 --
 include/linux/netfilter_ipv4/ipt_SAME.h  |   20 --------------------
 include/linux/netfilter_ipv4/ipt_realm.h |    7 -------
 3 files changed, 0 insertions(+), 29 deletions(-)
 delete mode 100644 include/linux/netfilter_ipv4/ipt_SAME.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_realm.h

diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index f9930c8..31f8bec 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -4,11 +4,9 @@ header-y += ipt_CLUSTERIP.h
 header-y += ipt_ECN.h
 header-y += ipt_LOG.h
 header-y += ipt_REJECT.h
-header-y += ipt_SAME.h
 header-y += ipt_TTL.h
 header-y += ipt_ULOG.h
 header-y += ipt_addrtype.h
 header-y += ipt_ah.h
 header-y += ipt_ecn.h
-header-y += ipt_realm.h
 header-y += ipt_ttl.h
diff --git a/include/linux/netfilter_ipv4/ipt_SAME.h b/include/linux/netfilter_ipv4/ipt_SAME.h
deleted file mode 100644
index 5bca782..0000000
--- a/include/linux/netfilter_ipv4/ipt_SAME.h
+++ /dev/null
@@ -1,20 +0,0 @@
-#ifndef _IPT_SAME_H
-#define _IPT_SAME_H
-
-#include <linux/types.h>
-
-#define IPT_SAME_MAX_RANGE	10
-
-#define IPT_SAME_NODST		0x01
-
-struct ipt_same_info {
-	unsigned char info;
-	__u32 rangesize;
-	__u32 ipnum;
-	__u32 *iparray;
-
-	/* hangs off end. */
-	struct nf_nat_range range[IPT_SAME_MAX_RANGE];
-};
-
-#endif /*_IPT_SAME_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_realm.h b/include/linux/netfilter_ipv4/ipt_realm.h
deleted file mode 100644
index b3996ea..0000000
--- a/include/linux/netfilter_ipv4/ipt_realm.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_REALM_H
-#define _IPT_REALM_H
-
-#include <linux/netfilter/xt_realm.h>
-#define ipt_realm_info xt_realm_info
-
-#endif /* _IPT_REALM_H */
-- 
1.7.7.3

