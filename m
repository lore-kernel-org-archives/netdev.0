From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] netfilter: fix checkpatch error for netfilter
Date: Thu, 19 Dec 2013 19:24:24 +0800
Message-ID: <1387452264-8896-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter@vger.kernel.org>
To: <pablo@netfilter.org>, <davem@davemloft.net>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:43138 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455Ab3LSLY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 06:24:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

This patch fix some checkpatch errors,clean up the code.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/netfilter/nf_tables_api.c | 4 ++--
 net/netfilter/xt_osf.c        | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index f93b7d0..045efa1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -130,7 +130,7 @@ static int __nf_tables_chain_type_lookup(int family, const struct nlattr *nla)
 {
 	int i;
 
-	for (i=0; i<NFT_CHAIN_T_MAX; i++) {
+	for (i = 0; i < NFT_CHAIN_T_MAX; i++) {
 		if (chain_type[family][i] != NULL &&
 		    !nla_strcmp(nla, chain_type[family][i]->name))
 			return i;
@@ -814,7 +814,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			      const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nlattr * uninitialized_var(name);
+	const struct nlattr *uninitialized_var(name);
 	const struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 7174611..b93154c 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -371,7 +371,7 @@ static int __init xt_osf_init(void)
 	int err = -EINVAL;
 	int i;
 
-	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i)
+	for (i = 0; i < ARRAY_SIZE(xt_osf_fingers); ++i)
 		INIT_LIST_HEAD(&xt_osf_fingers[i]);
 
 	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
@@ -404,7 +404,7 @@ static void __exit xt_osf_fini(void)
 	xt_unregister_match(&xt_osf_match);
 
 	rcu_read_lock();
-	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i) {
+	for (i = 0; i < ARRAY_SIZE(xt_osf_fingers); ++i) {
 
 		list_for_each_entry_rcu(f, &xt_osf_fingers[i], finger_entry) {
 			list_del_rcu(&f->finger_entry);
-- 
1.7.12
