From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 2/7] netfilter-ipv6: function definition layout
Date: Sun, 11 Oct 2015 17:32:15 +0100
Message-ID: <1444581140-6255-3-git-send-email-ipm@chirality.org.uk>
References: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use tabs instead of spaces to indent second line of parameters in
function definitions.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
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
1.9.1

