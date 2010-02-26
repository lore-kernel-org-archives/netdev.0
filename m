From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/03: xtables: restore indentation
Date: Fri, 26 Feb 2010 18:15:25 +0100 (MET)
Message-ID: <20100226171525.30040.44643.sendpatchset@x2.localnet>
References: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6b4ff2d7675511a31980fa5379808660e1261f90
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Feb 26 17:53:31 2010 +0100

    netfilter: xtables: restore indentation
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 57098dc..f07d77f 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -644,8 +644,10 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
 		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
-		      entry0 + repl->size, repl->hook_entry, repl->underflow,
-		      repl->valid_hooks);
+						 entry0 + repl->size,
+						 repl->hook_entry,
+						 repl->underflow,
+						 repl->valid_hooks);
 		if (ret != 0)
 			break;
 		++i;
@@ -730,7 +732,7 @@ static void get_counters(const struct xt_table_info *t,
 	i = 0;
 	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
 		SET_COUNTER(counters[i], iter->counters.bcnt,
-			iter->counters.pcnt);
+			    iter->counters.pcnt);
 		++i;
 	}
 
@@ -741,7 +743,7 @@ static void get_counters(const struct xt_table_info *t,
 		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
 			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				iter->counters.pcnt);
+				    iter->counters.pcnt);
 			++i;
 		}
 		xt_info_wrunlock(cpu);
@@ -1356,8 +1358,11 @@ static int translate_compat_table(const char *name,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
-		      entry0, entry0 + total_size, hook_entries, underflows,
-		      name);
+							entry0,
+							entry0 + total_size,
+							hook_entries,
+							underflows,
+							name);
 		if (ret != 0)
 			goto out_unlock;
 		++j;
@@ -1401,8 +1406,8 @@ static int translate_compat_table(const char *name,
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
-		ret = compat_copy_entry_from_user(iter0, &pos,
-		      &size, name, newinfo, entry1);
+		ret = compat_copy_entry_from_user(iter0, &pos, &size,
+						  name, newinfo, entry1);
 		if (ret != 0)
 			break;
 	}
@@ -1617,7 +1622,7 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
-		      &size, counters, i++);
+						&size, counters, i++);
 		if (ret != 0)
 			break;
 	}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index c92f4e5..b29c66d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -836,8 +836,10 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
 		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
-		      entry0 + repl->size, repl->hook_entry, repl->underflow,
-		      repl->valid_hooks);
+						 entry0 + repl->size,
+						 repl->hook_entry,
+						 repl->underflow,
+						 repl->valid_hooks);
 		if (ret != 0)
 			return ret;
 		++i;
@@ -918,7 +920,7 @@ get_counters(const struct xt_table_info *t,
 	i = 0;
 	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
 		SET_COUNTER(counters[i], iter->counters.bcnt,
-			iter->counters.pcnt);
+			    iter->counters.pcnt);
 		++i;
 	}
 
@@ -929,7 +931,7 @@ get_counters(const struct xt_table_info *t,
 		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
 			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				iter->counters.pcnt);
+				    iter->counters.pcnt);
 			++i; /* macro does multi eval of i */
 		}
 		xt_info_wrunlock(cpu);
@@ -1540,7 +1542,7 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
 		ret = compat_find_calc_match(ematch, name,
-		      &e->ip, e->comefrom, &off);
+					     &e->ip, e->comefrom, &off);
 		if (ret != 0)
 			goto release_matches;
 		++j;
@@ -1701,8 +1703,11 @@ translate_compat_table(struct net *net,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
-		      entry0, entry0 + total_size, hook_entries, underflows,
-		      name);
+							entry0,
+							entry0 + total_size,
+							hook_entries,
+							underflows,
+							name);
 		if (ret != 0)
 			goto out_unlock;
 		++j;
@@ -1746,8 +1751,8 @@ translate_compat_table(struct net *net,
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
-		ret = compat_copy_entry_from_user(iter0, &pos,
-		      &size, name, newinfo, entry1);
+		ret = compat_copy_entry_from_user(iter0, &pos, &size,
+						  name, newinfo, entry1);
 		if (ret != 0)
 			break;
 	}
@@ -1927,7 +1932,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
-		      &size, counters, i++);
+						&size, counters, i++);
 		if (ret != 0)
 			break;
 	}
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index f704286..9210e31 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -866,8 +866,10 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
 		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
-		      entry0 + repl->size, repl->hook_entry, repl->underflow,
-		      repl->valid_hooks);
+						 entry0 + repl->size,
+						 repl->hook_entry,
+						 repl->underflow,
+						 repl->valid_hooks);
 		if (ret != 0)
 			return ret;
 		++i;
@@ -948,7 +950,7 @@ get_counters(const struct xt_table_info *t,
 	i = 0;
 	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
 		SET_COUNTER(counters[i], iter->counters.bcnt,
-			iter->counters.pcnt);
+			    iter->counters.pcnt);
 		++i;
 	}
 
@@ -959,7 +961,7 @@ get_counters(const struct xt_table_info *t,
 		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
 			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				iter->counters.pcnt);
+				    iter->counters.pcnt);
 			++i;
 		}
 		xt_info_wrunlock(cpu);
@@ -1573,7 +1575,7 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
 		ret = compat_find_calc_match(ematch, name,
-		      &e->ipv6, e->comefrom, &off);
+					     &e->ipv6, e->comefrom, &off);
 		if (ret != 0)
 			goto release_matches;
 		++j;
@@ -1734,8 +1736,11 @@ translate_compat_table(struct net *net,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
-		      entry0, entry0 + total_size, hook_entries, underflows,
-		      name);
+							entry0,
+							entry0 + total_size,
+							hook_entries,
+							underflows,
+							name);
 		if (ret != 0)
 			goto out_unlock;
 		++j;
@@ -1779,8 +1784,8 @@ translate_compat_table(struct net *net,
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
-		ret = compat_copy_entry_from_user(iter0, &pos,
-		      &size, name, newinfo, entry1);
+		ret = compat_copy_entry_from_user(iter0, &pos, &size,
+						  name, newinfo, entry1);
 		if (ret != 0)
 			break;
 	}
@@ -1960,7 +1965,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
-		      &size, counters, i++);
+						&size, counters, i++);
 		if (ret != 0)
 			break;
 	}
