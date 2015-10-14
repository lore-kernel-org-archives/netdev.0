From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 1/6] netfilter-ipv4: Line layout whitespace fixes
Date: Wed, 14 Oct 2015 23:17:03 +0100
Message-ID: <1444861028-21556-2-git-send-email-ipm@chirality.org.uk>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanses some whitespace issues by removing a leading space before a tab.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv4/netfilter/ipt_ECN.c           | 2 +-
 net/ipv4/netfilter/nf_nat_pptp.c       | 2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 2707652..6592708 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -24,7 +24,7 @@ MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag modification");
 
 /* set ECT codepoint from IP header.
- * 	return false if there was an error. */
+ *	return false if there was an error. */
 static inline bool
 set_ect_ip(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 {
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 657d230..d5726f7 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -16,7 +16,7 @@
  * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * TODO: - NAT to a unique tuple, not to TCP source port
- * 	   (needs netfilter tuple reservation)
+ *	   (needs netfilter tuple reservation)
  */
 
 #include <linux/module.h>
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 7c67667..8e3dffa 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -891,7 +891,7 @@ static void fast_csum(__sum16 *csum,
 
 /*
  * Mangle IP address.
- * 	- begin points to the start of the snmp messgae
+ *	- begin points to the start of the snmp messgae
  *      - addr points to the start of the address
  */
 static inline void mangle_address(unsigned char *begin,
-- 
1.9.1

