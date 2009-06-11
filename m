From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] netfilter h323_asn1.c: convert PRINT to pr_info
Date: Thu, 11 Jun 2009 00:40:22 -0700
Message-ID: <2ea439ce497b44f587aad8d6867d4e64e94d7388.1244705154.git.joe@perches.com>
References: <cover.1244705154.git.joe@perches.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1244705154.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

only for #ifdef __KERNEL__ codepath

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/nf_conntrack_h323_asn1.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index 8678823..1134520 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -11,6 +11,7 @@
  ****************************************************************************/
 
 #ifdef __KERNEL__
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
 #include <linux/kernel.h>
 #else
 #include <stdio.h>
@@ -26,7 +27,7 @@
 #define TAB_SIZE 4
 #define IFTHEN(cond, act) if(cond){act;}
 #ifdef __KERNEL__
-#define PRINT printk
+#define PRINT pr_info
 #else
 #define PRINT printf
 #endif
-- 
1.6.3.1.10.g659a0.dirty

