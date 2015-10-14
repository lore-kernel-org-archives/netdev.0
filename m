From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 4/6] netfilter-ipv4: function definition layout
Date: Wed, 14 Oct 2015 23:17:06 +0100
Message-ID: <1444861028-21556-5-git-send-email-ipm@chirality.org.uk>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use tabs instead of spaces to indent second line of parameters in
function definitions.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv4/netfilter/arp_tables.c | 6 +++---
 net/ipv4/netfilter/ip_tables.c  | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index eb6663bd..11dccba 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -632,7 +632,7 @@ static inline void cleanup_entry(struct arpt_entry *e)
  * newinfo).
  */
 static int translate_table(struct xt_table_info *newinfo, void *entry0,
-                           const struct arpt_replace *repl)
+			   const struct arpt_replace *repl)
 {
 	struct arpt_entry *iter;
 	unsigned int i;
@@ -892,7 +892,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1069,7 +1069,7 @@ static int __do_replace(struct net *net, const char *name,
 }
 
 static int do_replace(struct net *net, const void __user *user,
-                      unsigned int len)
+		      unsigned int len)
 {
 	int ret;
 	struct arpt_replace tmp;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 08b7ab0..3991a87 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -804,7 +804,7 @@ cleanup_entry(struct ipt_entry *e, struct net *net)
    newinfo) */
 static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
-                const struct ipt_replace *repl)
+		const struct ipt_replace *repl)
 {
 	struct ipt_entry *iter;
 	unsigned int i;
@@ -1078,7 +1078,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1304,7 +1304,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 
 static int
 do_add_counters(struct net *net, const void __user *user,
-                unsigned int len, int compat)
+		unsigned int len, int compat)
 {
 	unsigned int i;
 	struct xt_counters_info tmp;
-- 
1.9.1

