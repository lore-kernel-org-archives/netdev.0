From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/23] netfilter-bridge: Cleanse indentation
Date: Fri, 18 Dec 2015 21:26:29 +0100
Message-ID: <1450470409-31427-4-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57930 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965049AbbLRUeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:02 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 6F85C12927C
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0CA3BDA85D
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 02AA04CA26
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:37 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Fixes a bunch of issues detected by checkpatch with regards to code
indentation.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_stp.c        |  2 +-
 net/bridge/netfilter/ebtable_filter.c |  2 +-
 net/bridge/netfilter/ebtable_nat.c    |  2 +-
 net/bridge/netfilter/ebtables.c       | 44 +++++++++++++++++------------------
 4 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 0c40570..6b731e1 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -41,7 +41,7 @@ struct stp_config_pdu {
 #define NR32(p) ((p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3])
 
 static bool ebt_filter_config(const struct ebt_stp_info *info,
-   const struct stp_config_pdu *stpc)
+			      const struct stp_config_pdu *stpc)
 {
 	const struct ebt_stp_config_info *c;
 	uint16_t v16;
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 32eccd1..593a1bdc 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -12,7 +12,7 @@
 #include <linux/module.h>
 
 #define FILTER_VALID_HOOKS ((1 << NF_BR_LOCAL_IN) | (1 << NF_BR_FORWARD) | \
-   (1 << NF_BR_LOCAL_OUT))
+			    (1 << NF_BR_LOCAL_OUT))
 
 static struct ebt_entries initial_chains[] = {
 	{
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index ec55358..eb33919 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -12,7 +12,7 @@
 #include <linux/module.h>
 
 #define NAT_VALID_HOOKS ((1 << NF_BR_PRE_ROUTING) | (1 << NF_BR_LOCAL_OUT) | \
-   (1 << NF_BR_POST_ROUTING))
+			 (1 << NF_BR_POST_ROUTING))
 
 static struct ebt_entries initial_chains[] = {
 	{
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index f46ca41..2a0b2f6 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -46,7 +46,7 @@
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 #define COUNTER_OFFSET(n) (SMP_ALIGN(n * sizeof(struct ebt_counter)))
 #define COUNTER_BASE(c, n, cpu) ((struct ebt_counter *)(((char *)c) + \
-   COUNTER_OFFSET(n) * cpu))
+				 COUNTER_OFFSET(n) * cpu))
 
 
 
@@ -126,7 +126,7 @@ ebt_dev_check(const char *entry, const struct net_device *device)
 /* process standard matches */
 static inline int
 ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
-                const struct net_device *in, const struct net_device *out)
+		const struct net_device *in, const struct net_device *out)
 {
 	const struct ethhdr *h = eth_hdr(skb);
 	const struct net_bridge_port *p;
@@ -323,7 +323,7 @@ letscontinue:
 /* If it succeeds, returns element and locks mutex */
 static inline void *
 find_inlist_lock_noload(struct list_head *head, const char *name, int *error,
-   struct mutex *mutex)
+			struct mutex *mutex)
 {
 	struct {
 		struct list_head list;
@@ -342,7 +342,7 @@ find_inlist_lock_noload(struct list_head *head, const char *name, int *error,
 
 static void *
 find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
-   int *error, struct mutex *mutex)
+		 int *error, struct mutex *mutex)
 {
 	return try_then_request_module(
 			find_inlist_lock_noload(head, name, error, mutex),
@@ -493,9 +493,9 @@ static int ebt_verify_pointers(const struct ebt_replace *repl,
  */
 static inline int
 ebt_check_entry_size_and_hooks(const struct ebt_entry *e,
-   const struct ebt_table_info *newinfo,
-   unsigned int *n, unsigned int *cnt,
-   unsigned int *totalcnt, unsigned int *udc_cnt)
+			       const struct ebt_table_info *newinfo,
+			       unsigned int *n, unsigned int *cnt,
+			       unsigned int *totalcnt, unsigned int *udc_cnt)
 {
 	int i;
 
@@ -562,7 +562,7 @@ struct ebt_cl_stack
  */
 static inline int
 ebt_get_udc_positions(struct ebt_entry *e, struct ebt_table_info *newinfo,
-   unsigned int *n, struct ebt_cl_stack *udc)
+		      unsigned int *n, struct ebt_cl_stack *udc)
 {
 	int i;
 
@@ -649,9 +649,9 @@ ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 
 static inline int
 ebt_check_entry(struct ebt_entry *e, struct net *net,
-   const struct ebt_table_info *newinfo,
-   const char *name, unsigned int *cnt,
-   struct ebt_cl_stack *cl_s, unsigned int udc_cnt)
+		const struct ebt_table_info *newinfo,
+		const char *name, unsigned int *cnt,
+		struct ebt_cl_stack *cl_s, unsigned int udc_cnt)
 {
 	struct ebt_entry_target *t;
 	struct xt_target *target;
@@ -764,7 +764,7 @@ cleanup_matches:
  * accessed. This mask is a parameter to the check() functions of the extensions
  */
 static int check_chainloops(const struct ebt_entries *chain, struct ebt_cl_stack *cl_s,
-   unsigned int udc_cnt, unsigned int hooknr, char *base)
+			    unsigned int udc_cnt, unsigned int hooknr, char *base)
 {
 	int i, chain_nr = -1, pos = 0, nentries = chain->nentries, verdict;
 	const struct ebt_entry *e = (struct ebt_entry *)chain->data;
@@ -955,7 +955,7 @@ static int translate_table(struct net *net, const char *name,
 
 /* called under write_lock */
 static void get_counters(const struct ebt_counter *oldcounters,
-   struct ebt_counter *counters, unsigned int nentries)
+			 struct ebt_counter *counters, unsigned int nentries)
 {
 	int i, cpu;
 	struct ebt_counter *counter_base;
@@ -1342,7 +1342,7 @@ static int update_counters(struct net *net, const void __user *user,
 }
 
 static inline int ebt_make_matchname(const struct ebt_entry_match *m,
-    const char *base, char __user *ubase)
+				     const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)m - base);
 	char name[EBT_FUNCTION_MAXNAMELEN] = {};
@@ -1356,7 +1356,7 @@ static inline int ebt_make_matchname(const struct ebt_entry_match *m,
 }
 
 static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
-    const char *base, char __user *ubase)
+				       const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)w - base);
 	char name[EBT_FUNCTION_MAXNAMELEN] = {};
@@ -1367,8 +1367,8 @@ static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
 	return 0;
 }
 
-static inline int
-ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
+static inline int ebt_make_names(struct ebt_entry *e, const char *base,
+				 char __user *ubase)
 {
 	int ret;
 	char __user *hlp;
@@ -1394,9 +1394,9 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 }
 
 static int copy_counters_to_user(struct ebt_table *t,
-				  const struct ebt_counter *oldcounters,
-				  void __user *user, unsigned int num_counters,
-				  unsigned int nentries)
+				 const struct ebt_counter *oldcounters,
+				 void __user *user, unsigned int num_counters,
+				 unsigned int nentries)
 {
 	struct ebt_counter *counterstmp;
 	int ret = 0;
@@ -1427,7 +1427,7 @@ static int copy_counters_to_user(struct ebt_table *t,
 
 /* called with ebt_mutex locked */
 static int copy_everything_to_user(struct ebt_table *t, void __user *user,
-    const int *len, int cmd)
+				   const int *len, int cmd)
 {
 	struct ebt_replace tmp;
 	const struct ebt_counter *oldcounters;
@@ -2305,7 +2305,7 @@ static int compat_do_ebt_set_ctl(struct sock *sk,
 		break;
 	default:
 		ret = -EINVAL;
-  }
+	}
 	return ret;
 }
 
-- 
2.1.4
