From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/35] netfilter: ip6_tables: function definition layout
Date: Sat, 17 Oct 2015 13:32:54 +0200
Message-ID: <1445081590-2924-20-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48403 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740AbbJQL0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:24 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Use tabs instead of spaces to indent second line of parameters in
function definitions.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6_tables.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 67a2821..0654312 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -816,7 +816,7 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
    newinfo) */
 static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
-                const struct ip6t_replace *repl)
+		const struct ip6t_replace *repl)
 {
 	struct ip6t_entry *iter;
 	unsigned int i;
@@ -1090,7 +1090,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1152,7 +1152,7 @@ static int get_info(struct net *net, void __user *user,
 
 static int
 get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
-            const int *len)
+	    const int *len)
 {
 	int ret;
 	struct ip6t_get_entries get;
-- 
2.1.4
