From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] netfilter: remove ipt_SAME.h and ipt_realm.h too
Date: Fri,  3 Feb 2012 18:02:31 +0800
Message-ID: <1328263351-29363-1-git-send-email-xiyou.wangcong@gmail.com>
References: <20120203081511.GD30546@Chamillionaire.breakpoint.cc>
Cc: netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120203081511.GD30546@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As Florian pointed out, these 2 headers can be removed too.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index 8e6362b..5ec78b6 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -4,10 +4,8 @@ header-y += ipt_CLUSTERIP.h
 header-y += ipt_ECN.h
 header-y += ipt_LOG.h
 header-y += ipt_REJECT.h
-header-y += ipt_SAME.h
 header-y += ipt_TTL.h
 header-y += ipt_ULOG.h
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
