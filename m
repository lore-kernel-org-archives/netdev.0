From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 09/12] headers, xtables: Add missing #include
 <linux/netfilter.h>
Date: Mon, 08 Aug 2011 14:20:32 +0100
Message-ID: <1312809632.2591.1148.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various headers use union nf_inet_addr, defined in <linux/netfilter.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/netfilter/xt_connlimit.h |    1 +
 include/linux/netfilter/xt_conntrack.h |    1 +
 include/linux/netfilter/xt_iprange.h   |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_connlimit.h b/include/linux/netfilter/xt_connlimit.h
index 0ca66e9..d1366f0 100644
--- a/include/linux/netfilter/xt_connlimit.h
+++ b/include/linux/netfilter/xt_connlimit.h
@@ -2,6 +2,7 @@
 #define _XT_CONNLIMIT_H
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 
 struct xt_connlimit_data;
 
diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilter/xt_conntrack.h
index 74b904d..e3c041d 100644
--- a/include/linux/netfilter/xt_conntrack.h
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -6,6 +6,7 @@
 #define _XT_CONNTRACK_H
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 
 #define XT_CONNTRACK_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
diff --git a/include/linux/netfilter/xt_iprange.h b/include/linux/netfilter/xt_iprange.h
index c1f21a7..25fd7cf 100644
--- a/include/linux/netfilter/xt_iprange.h
+++ b/include/linux/netfilter/xt_iprange.h
@@ -2,6 +2,7 @@
 #define _LINUX_NETFILTER_XT_IPRANGE_H 1
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 
 enum {
 	IPRANGE_SRC     = 1 << 0,	/* match source IP address */
-- 
1.7.5.4



