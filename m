From: Lucas Tanure <tanure@linux.com>
Subject: [PATCH 4/4] netfilter: ipv4: spaces preferred around operators
Date: Sat, 30 Jan 2016 11:17:58 -0200
Message-ID: <1454159878-20706-4-git-send-email-tanure@linux.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454159878-20706-1-git-send-email-tanure@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the checkpatch.pl issues:
CHECK: spaces preferred around that '&' (ctx:VxV)
CHECK: spaces preferred around that '<<' (ctx:VxV)
CHECK: spaces preferred around that '-' (ctx:VxV)
CHECK: spaces preferred around that '+' (ctx:VxV)

Signed-off-by: Lucas Tanure <tanure@linux.com>
---
 net/ipv4/netfilter/ip_tables.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index dcc61c0..6f29382 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -82,9 +82,9 @@ ip_packet_match(const struct iphdr *ip,
 
 #define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
 
-	if (FWINV((ip->saddr&ipinfo->smsk.s_addr) != ipinfo->src.s_addr,
+	if (FWINV((ip->saddr & ipinfo->smsk.s_addr) != ipinfo->src.s_addr,
 		  IPT_INV_SRCIP) ||
-	    FWINV((ip->daddr&ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr,
+	    FWINV((ip->daddr & ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr,
 		  IPT_INV_DSTIP)) {
 		dprintf("Source or dest mismatch.\n");
 
@@ -126,7 +126,7 @@ ip_packet_match(const struct iphdr *ip,
 
 	/* If we have a fragment rule but the packet is not a fragment
 	 * then we return zero */
-	if (FWINV((ipinfo->flags&IPT_F_FRAG) && !isfrag, IPT_INV_FRAG)) {
+	if (FWINV((ipinfo->flags & IPT_F_FRAG) && !isfrag, IPT_INV_FRAG)) {
 		dprintf("Fragment rule but not fragment.%s\n",
 			ipinfo->invflags & IPT_INV_FRAG ? " (INV)" : "");
 		return false;
@@ -496,7 +496,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				/* Return: backtrack through the last
 				   big jump. */
 				do {
-					e->comefrom ^= (1<<NF_INET_NUMHOOKS);
+					e->comefrom ^= (1 << NF_INET_NUMHOOKS);
 #ifdef DEBUG_IP_FIREWALL_USER
 					if (e->comefrom
 					    & (1 << NF_INET_NUMHOOKS)) {
@@ -981,7 +981,7 @@ copy_entries_to_user(unsigned int total_size,
 					 + offsetof(struct xt_entry_match,
 						    u.user.name),
 					 m->u.kernel.match->name,
-					 strlen(m->u.kernel.match->name)+1)
+					 strlen(m->u.kernel.match->name) + 1)
 			    != 0) {
 				ret = -EFAULT;
 				goto free_counters;
@@ -993,7 +993,7 @@ copy_entries_to_user(unsigned int total_size,
 				 + offsetof(struct xt_entry_target,
 					    u.user.name),
 				 t->u.kernel.target->name,
-				 strlen(t->u.kernel.target->name)+1) != 0) {
+				 strlen(t->u.kernel.target->name) + 1) != 0) {
 			ret = -EFAULT;
 			goto free_counters;
 		}
@@ -1094,7 +1094,7 @@ static int get_info(struct net *net, void __user *user,
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
 
-	name[XT_TABLE_MAXNAMELEN-1] = '\0';
+	name[XT_TABLE_MAXNAMELEN - 1] = '\0';
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_lock(AF_INET);
@@ -1270,7 +1270,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (tmp.num_counters == 0)
 		return -EINVAL;
 
-	tmp.name[sizeof(tmp.name)-1] = 0;
+	tmp.name[sizeof(tmp.name) - 1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
 	if (!newinfo)
@@ -1818,7 +1818,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	if (tmp.num_counters == 0)
 		return -EINVAL;
 
-	tmp.name[sizeof(tmp.name)-1] = 0;
+	tmp.name[sizeof(tmp.name) - 1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
 	if (!newinfo)
@@ -2041,7 +2041,7 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EFAULT;
 			break;
 		}
-		rev.name[sizeof(rev.name)-1] = 0;
+		rev.name[sizeof(rev.name) - 1] = 0;
 
 		if (cmd == IPT_SO_GET_REVISION_TARGET)
 			target = 1;
@@ -2155,7 +2155,7 @@ icmp_match(const struct sk_buff *skb, struct xt_action_param *par)
 				    icmpinfo->code[0],
 				    icmpinfo->code[1],
 				    ic->type, ic->code,
-				    !!(icmpinfo->invflags&IPT_ICMP_INV));
+				    !!(icmpinfo->invflags & IPT_ICMP_INV));
 }
 
 static int icmp_checkentry(const struct xt_mtchk_param *par)
@@ -2188,13 +2188,13 @@ static struct xt_target ipt_builtin_tg[] __read_mostly = {
 static struct nf_sockopt_ops ipt_sockopts = {
 	.pf		= PF_INET,
 	.set_optmin	= IPT_BASE_CTL,
-	.set_optmax	= IPT_SO_SET_MAX+1,
+	.set_optmax	= IPT_SO_SET_MAX + 1,
 	.set		= do_ipt_set_ctl,
 #ifdef CONFIG_COMPAT
 	.compat_set	= compat_do_ipt_set_ctl,
 #endif
 	.get_optmin	= IPT_BASE_CTL,
-	.get_optmax	= IPT_SO_GET_MAX+1,
+	.get_optmax	= IPT_SO_GET_MAX + 1,
 	.get		= do_ipt_get_ctl,
 #ifdef CONFIG_COMPAT
 	.compat_get	= compat_do_ipt_get_ctl,
-- 
2.7.0
