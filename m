From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] IPV6 Updates
Date: Fri, 04 Mar 2005 12:10:10 +0900 (JST)
Message-ID: <20050304.121010.06175310.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull the following changesets available at:
	bk://bk.skbuff.net:20612/linux-2.6-inet6-01a_v6ready2/

After all, we can pass IPv6 Ready Logo Phase 1,2 Self Test2
without FAILs.

HEADLINES
---------
ChangeSet@1.2080, 2005-03-03 14:35:45+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Fix space calculation for link-layer address options.
ChangeSet@1.2081, 2005-03-03 14:35:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Save space for ndisc_options{}.
ChangeSet@1.2082, 2005-03-03 14:36:11+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Make ndisc_opt_lladdr_data() and check length inside.
ChangeSet@1.2083, 2005-03-03 14:36:24+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ROUTE: Add gc_min_interval_ms sysctl.
ChangeSet@1.2084, 2005-03-03 14:36:36+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Ensure to notify up-to-date link information.
ChangeSet@1.2085, 2005-03-03 14:36:49+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: Add hook for sysctl strategy.
ChangeSet@1.2086, 2005-03-03 14:37:02+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: NEWLINK notification on change of Reachable Time
ChangeSet@1.2087, 2005-03-03 14:37:14+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Recompute Reachable Time on change of Base Reachable Time.
ChangeSet@1.2088, 2005-03-03 14:37:28+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: Add retrans_time_ms and reachable_time_ms sysctls.
ChangeSet@1.2089, 2005-03-03 14:37:40+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Deprecate base_reachable_time and retrans_timer.
ChangeSet@1.2090, 2005-03-03 14:37:53+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ROUTE: Keep cache entries for a while.
ChangeSet@1.2091, 2005-03-03 14:38:06+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Ensure to send redirects.
ChangeSet@1.2092, 2005-03-03 14:38:18+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Ensure to send redirects even if we don't know target's lladdr.
ChangeSet@1.2093, 2005-03-03 14:38:31+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Always add a fragment header after receiving TOO BIG w/ pmtu < 1280.
ChangeSet@1.2094, 2005-03-03 14:38:44+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Ensure to use interface hoplimit by default.
ChangeSet@1.2095, 2005-03-03 14:38:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Unify common functions to compare ipv6 prefixes.
ChangeSet@1.2096, 2005-03-03 14:39:10+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ADDRCONF: Update prefix route on address deletion.
ChangeSet@1.2097, 2005-03-03 14:39:22+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Mature enough, no longer EXPERIMENTAL.
ChangeSet@1.2098, 2005-03-03 14:39:35+09:00, yoshfuji@linux-ipv6.org
 [NET] Don't use magic number for sysctl table definition.


DIFFSTATS
---------
 net/ipv6/README                    |    8 -
 net/ipv6/addrconf.c                |   62 -----------
 net/ipv6/route.c                   |    9 -
 Documentation/filesystems/proc.txt |   21 ++-
 include/linux/ip.h                 |    1 
 include/linux/rtnetlink.h          |    1 
 include/linux/sysctl.h             |   12 +-
 include/net/addrconf.h             |    2 
 include/net/dst.h                  |    9 +
 include/net/ipv6.h                 |   26 ++++
 include/net/ndisc.h                |   14 +-
 include/net/neighbour.h            |    3 
 net/Kconfig                        |   23 +---
 net/core/neighbour.c               |   53 ++++++++-
 net/ipv4/arp.c                     |    2 
 net/ipv4/devinet.c                 |    6 -
 net/ipv6/addrconf.c                |   13 --
 net/ipv6/anycast.c                 |   30 -----
 net/ipv6/icmp.c                    |    4 
 net/ipv6/ip6_fib.c                 |   38 -------
 net/ipv6/ip6_output.c              |   12 +-
 net/ipv6/ndisc.c                   |  197 +++++++++++++++++++++++++++----------
 net/ipv6/netfilter/Kconfig         |    4 
 net/ipv6/raw.c                     |    2 
 net/ipv6/route.c                   |  117 ++++++++++-----------
 net/ipv6/udp.c                     |    2 
 26 files changed, 361 insertions(+), 310 deletions(-)


CHANGESETS
----------
ChangeSet@1.2080, 2005-03-03 14:35:45+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Fix space calculation for link-layer address options.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:32:44 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:32:44 +09:00
@@ -183,6 +183,11 @@
 	}
 }
 
+static inline int ndisc_opt_addr_space(struct net_device *dev)
+{
+	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
+}
+
 static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
 				  unsigned short addr_type)
 {
@@ -439,7 +444,7 @@
 
 	if (inc_opt) {
 		if (dev->addr_len)
-			len += NDISC_OPT_SPACE(dev->addr_len);
+			len += ndisc_opt_addr_space(dev);
 		else
 			inc_opt = 0;
 	}
@@ -532,7 +537,7 @@
 	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
 	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
 	if (send_llinfo)
-		len += NDISC_OPT_SPACE(dev->addr_len);
+		len += ndisc_opt_addr_space(dev);
 
 	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
@@ -608,7 +613,7 @@
 
 	len = sizeof(struct icmp6hdr);
 	if (dev->addr_len)
-		len += NDISC_OPT_SPACE(dev->addr_len);
+		len += ndisc_opt_addr_space(dev);
 
         skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
@@ -744,7 +749,7 @@
 		lladdr = (u8*)(ndopts.nd_opts_src_lladdr + 1) +
 			ndisc_addr_option_pad(dev->type);
 		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
+		if (lladdrlen != ndisc_opt_addr_space(dev)) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 NS: invalid link-layer address length\n");
 			return;
@@ -902,7 +907,7 @@
 		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1) +
 			ndisc_addr_option_pad(dev->type);
 		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
+		if (lladdrlen != ndisc_opt_addr_space(dev)) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 NA: invalid link-layer address length\n");
 			return;
@@ -997,7 +1002,7 @@
 		lladdr = (u8 *)(ndopts.nd_opts_src_lladdr + 1) +
 			ndisc_addr_option_pad(skb->dev->type);
 		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len))
+		if (lladdrlen != ndisc_opt_addr_space(skb->dev))
 			goto out;
 	}
 
@@ -1171,7 +1176,7 @@
 			lladdr = (u8*)((ndopts.nd_opts_src_lladdr)+1) +
 				ndisc_addr_option_pad(skb->dev->type);
 			lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-			if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
+			if (lladdrlen != ndisc_opt_addr_space(skb->dev)) {
 				ND_PRINTK2(KERN_WARNING
 					   "ICMPv6 RA: invalid link-layer address length\n");
 				goto out;
@@ -1294,7 +1299,7 @@
 		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1) +
 			ndisc_addr_option_pad(skb->dev->type);
 		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
+		if (lladdrlen != ndisc_opt_addr_space(skb->dev)) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 Redirect: invalid link-layer address length\n");
 			in6_dev_put(in6_dev);
@@ -1367,7 +1372,7 @@
 
 	if (dev->addr_len) {
 		if (neigh->nud_state&NUD_VALID) {
-			len  += NDISC_OPT_SPACE(dev->addr_len);
+			len  += ndisc_opt_addr_space(dev);
 		} else {
 			/* If nexthop is not valid, do not redirect!
 			   We will make it later, when will be sure,

ChangeSet@1.2081, 2005-03-03 14:35:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Save space for ndisc_options{}.
 
 Pointed out by Krishna Kumar <kumarkr@us.ibm.com>.
 
 Also, size of structure is now adjusted automatically.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ndisc.h b/include/net/ndisc.h
--- a/include/net/ndisc.h	2005-03-03 16:32:49 +09:00
+++ b/include/net/ndisc.h	2005-03-03 16:32:49 +09:00
@@ -15,11 +15,15 @@
  *	ndisc options
  */
 
-#define ND_OPT_SOURCE_LL_ADDR		1
-#define ND_OPT_TARGET_LL_ADDR		2
-#define ND_OPT_PREFIX_INFO		3
-#define ND_OPT_REDIRECT_HDR		4
-#define ND_OPT_MTU			5
+enum {
+	__ND_OPT_PREFIX_INFO_END = 0,
+	ND_OPT_SOURCE_LL_ADDR = 1,	/* RFC2461 */
+	ND_OPT_TARGET_LL_ADDR = 2,	/* RFC2461 */
+	ND_OPT_PREFIX_INFO = 3,		/* RFC2461 */
+	ND_OPT_REDIRECT_HDR = 4,	/* RFC2461 */
+	ND_OPT_MTU = 5,			/* RFC2461 */
+	__ND_OPT_MAX
+};
 
 #define MAX_RTR_SOLICITATION_DELAY	HZ
 
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:32:49 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:32:49 +09:00
@@ -156,14 +156,13 @@
 
 /* ND options */
 struct ndisc_options {
-	struct nd_opt_hdr *nd_opt_array[7];
-	struct nd_opt_hdr *nd_opt_piend;
+	struct nd_opt_hdr *nd_opt_array[__ND_OPT_MAX];
 };
 
 #define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
 #define nd_opts_tgt_lladdr	nd_opt_array[ND_OPT_TARGET_LL_ADDR]
 #define nd_opts_pi		nd_opt_array[ND_OPT_PREFIX_INFO]
-#define nd_opts_pi_end		nd_opt_piend
+#define nd_opts_pi_end		nd_opt_array[__ND_OPT_PREFIX_INFO_END]
 #define nd_opts_rh		nd_opt_array[ND_OPT_REDIRECT_HDR]
 #define nd_opts_mtu		nd_opt_array[ND_OPT_MTU]
 

ChangeSet@1.2082, 2005-03-03 14:36:11+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Make ndisc_opt_lladdr_data() and check length inside.
 
 What we should do is to check lladdrlen and get pointer
 for link-layer address option.
 Since we know lladdrlen == dev->addr_len, we can check inside.
 
 Singned-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:32:53 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:32:53 +09:00
@@ -271,6 +271,17 @@
 	return ndopts;
 }
 
+static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
+				      struct net_device *dev)
+{
+	u8 *lladdr = (u8 *)(p + 1);
+	int lladdrlen = p->nd_opt_len << 3;
+	int prepad = ndisc_addr_option_pad(dev->type);
+	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len + prepad))
+		return NULL;
+	return (lladdr + prepad);
+}
+
 int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
 {
 	switch (dev->type) {
@@ -708,7 +719,6 @@
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
 	struct in6_addr *daddr = &skb->nh.ipv6h->daddr;
 	u8 *lladdr = NULL;
-	int lladdrlen = 0;
 	u32 ndoptlen = skb->tail - msg->opt;
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
@@ -745,10 +755,8 @@
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_src_lladdr + 1) +
-			ndisc_addr_option_pad(dev->type);
-		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-		if (lladdrlen != ndisc_opt_addr_space(dev)) {
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev);
+		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 NS: invalid link-layer address length\n");
 			return;
@@ -871,7 +879,6 @@
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
 	struct in6_addr *daddr = &skb->nh.ipv6h->daddr;
 	u8 *lladdr = NULL;
-	int lladdrlen = 0;
 	u32 ndoptlen = skb->tail - msg->opt;
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
@@ -903,10 +910,8 @@
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1) +
-			ndisc_addr_option_pad(dev->type);
-		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
-		if (lladdrlen != ndisc_opt_addr_space(dev)) {
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev);
+		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 NA: invalid link-layer address length\n");
 			return;
@@ -967,7 +972,6 @@
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
 	struct ndisc_options ndopts;
 	u8 *lladdr = NULL;
-	int lladdrlen = 0;
 
 	if (skb->len < sizeof(*rs_msg))
 		return;
@@ -998,10 +1002,9 @@
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = (u8 *)(ndopts.nd_opts_src_lladdr + 1) +
-			ndisc_addr_option_pad(skb->dev->type);
-		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-		if (lladdrlen != ndisc_opt_addr_space(skb->dev))
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
+					     skb->dev);
+		if (!lladdr)
 			goto out;
 	}
 
@@ -1170,12 +1173,10 @@
 				       skb->dev, 1);
 	if (neigh) {
 		u8 *lladdr = NULL;
-		int lladdrlen;
 		if (ndopts.nd_opts_src_lladdr) {
-			lladdr = (u8*)((ndopts.nd_opts_src_lladdr)+1) +
-				ndisc_addr_option_pad(skb->dev->type);
-			lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-			if (lladdrlen != ndisc_opt_addr_space(skb->dev)) {
+			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
+						     skb->dev);
+			if (!lladdr) {
 				ND_PRINTK2(KERN_WARNING
 					   "ICMPv6 RA: invalid link-layer address length\n");
 				goto out;
@@ -1240,7 +1241,6 @@
 	struct ndisc_options ndopts;
 	int optlen;
 	u8 *lladdr = NULL;
-	int lladdrlen;
 
 	if (!(ipv6_addr_type(&skb->nh.ipv6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING
@@ -1295,10 +1295,9 @@
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1) +
-			ndisc_addr_option_pad(skb->dev->type);
-		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
-		if (lladdrlen != ndisc_opt_addr_space(skb->dev)) {
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
+					     skb->dev);
+		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 Redirect: invalid link-layer address length\n");
 			in6_dev_put(in6_dev);

ChangeSet@1.2083, 2005-03-03 14:36:24+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ROUTE: Add gc_min_interval_ms sysctl.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-03-03 16:32:58 +09:00
+++ b/include/linux/sysctl.h	2005-03-03 16:32:58 +09:00
@@ -455,7 +455,8 @@
 	NET_IPV6_ROUTE_GC_INTERVAL=6,
 	NET_IPV6_ROUTE_GC_ELASTICITY=7,
 	NET_IPV6_ROUTE_MTU_EXPIRES=8,
-	NET_IPV6_ROUTE_MIN_ADVMSS=9
+	NET_IPV6_ROUTE_MIN_ADVMSS=9,
+	NET_IPV6_ROUTE_GC_MIN_INTERVAL_MS=10
 };
 
 enum {
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2005-03-03 16:32:58 +09:00
+++ b/net/ipv6/route.c	2005-03-03 16:32:58 +09:00
@@ -2080,6 +2080,15 @@
          	.proc_handler	=	&proc_dointvec_jiffies,
 		.strategy	=	&sysctl_jiffies,
 	},
+	{
+		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL_MS,
+		.procname	=	"gc_min_interval_ms",
+         	.data		=	&ip6_rt_gc_min_interval,
+		.maxlen		=	sizeof(int),
+		.mode		=	0644,
+         	.proc_handler	=	&proc_dointvec_ms_jiffies,
+		.strategy	=	&sysctl_ms_jiffies,
+	},
 	{ .ctl_name = 0 }
 };
 

ChangeSet@1.2084, 2005-03-03 14:36:36+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Ensure to notify up-to-date link information.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:03 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:03 +09:00
@@ -1540,13 +1540,16 @@
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
+	int ret;
+	
+	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
 
-	if (write && dev && (idev = in6_dev_get(dev)) != NULL) {
+	if (write && ret == 0 && dev && (idev = in6_dev_get(dev)) != NULL) {
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);
 		in6_dev_put(idev);
 	}
-	return proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	return ret;
 }
 #endif
 

ChangeSet@1.2085, 2005-03-03 14:36:49+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: Add hook for sysctl strategy.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2005-03-03 16:33:07 +09:00
+++ b/include/net/neighbour.h	2005-03-03 16:33:07 +09:00
@@ -274,7 +274,8 @@
 						      struct neigh_parms *p,
 						      int p_id, int pdev_id,
 						      char *p_name,
-						      proc_handler *proc_handler);
+						      proc_handler *proc_handler,
+						      ctl_handler *strategy);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2005-03-03 16:33:07 +09:00
+++ b/net/core/neighbour.c	2005-03-03 16:33:07 +09:00
@@ -2200,7 +2200,7 @@
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 			  int p_id, int pdev_id, char *p_name, 
-			  proc_handler *handler)
+			  proc_handler *handler, ctl_handler *strategy)
 {
 	struct neigh_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
 	const char *dev_name_source = NULL;
@@ -2214,8 +2214,9 @@
 	t->neigh_vars[1].data  = &p->ucast_probes;
 	t->neigh_vars[2].data  = &p->app_probes;
 	t->neigh_vars[3].data  = &p->retrans_time;
-	if (handler) {
+	if (handler || strategy) {
 		t->neigh_vars[3].proc_handler = handler;
+		t->neigh_vars[3].strategy = strategy;
 		t->neigh_vars[3].extra1 = dev;
 	}
 	t->neigh_vars[4].data  = &p->base_reachable_time;
diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	2005-03-03 16:33:07 +09:00
+++ b/net/ipv4/arp.c	2005-03-03 16:33:07 +09:00
@@ -1243,7 +1243,7 @@
 	arp_proc_init();
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL);
+			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
 #endif
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2005-03-03 16:33:07 +09:00
+++ b/net/ipv4/devinet.c	2005-03-03 16:33:07 +09:00
@@ -153,7 +153,7 @@
 	dev_hold(dev);
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL);
+			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
 #endif
 
 	/* Account for reference dev->ip_ptr */
@@ -992,7 +992,7 @@
 		devinet_sysctl_unregister(&in_dev->cnf);
 		neigh_sysctl_unregister(in_dev->arp_parms);
 		neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-				      NET_IPV4_NEIGH, "ipv4", NULL);
+				      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
 		devinet_sysctl_register(in_dev, &in_dev->cnf);
 #endif
 		break;
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2005-03-03 16:33:07 +09:00
+++ b/net/ipv6/addrconf.c	2005-03-03 16:33:07 +09:00
@@ -391,7 +391,9 @@
 		ndev->tstamp = jiffies;
 #ifdef CONFIG_SYSCTL
 		neigh_sysctl_register(dev, ndev->nd_parms, NET_IPV6, 
-			NET_IPV6_NEIGH, "ipv6", &ndisc_ifinfo_sysctl_change);
+				      NET_IPV6_NEIGH, "ipv6",
+				      &ndisc_ifinfo_sysctl_change,
+				      NULL);
 		addrconf_sysctl_register(ndev, &ndev->cnf);
 #endif
 	}
@@ -1982,7 +1984,10 @@
 		if (idev) {
 			addrconf_sysctl_unregister(&idev->cnf);
 			neigh_sysctl_unregister(idev->nd_parms);
-			neigh_sysctl_register(dev, idev->nd_parms, NET_IPV6, NET_IPV6_NEIGH, "ipv6", &ndisc_ifinfo_sysctl_change);
+			neigh_sysctl_register(dev, idev->nd_parms,
+					      NET_IPV6, NET_IPV6_NEIGH, "ipv6",
+					      &ndisc_ifinfo_sysctl_change,
+					      NULL);
 			addrconf_sysctl_register(idev, &idev->cnf);
 		}
 #endif
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:07 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:07 +09:00
@@ -1584,7 +1584,7 @@
 
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, 
-			      "ipv6", &ndisc_ifinfo_sysctl_change);
+			      "ipv6", &ndisc_ifinfo_sysctl_change, NULL);
 #endif
 
 	register_netdevice_notifier(&ndisc_netdev_notifier);

ChangeSet@1.2086, 2005-03-03 14:37:02+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: NEWLINK notification on change of Reachable Time
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2005-03-03 16:33:12 +09:00
+++ b/net/core/neighbour.c	2005-03-03 16:33:12 +09:00
@@ -2215,9 +2215,14 @@
 	t->neigh_vars[2].data  = &p->app_probes;
 	t->neigh_vars[3].data  = &p->retrans_time;
 	if (handler || strategy) {
+		/* RetransTime */
 		t->neigh_vars[3].proc_handler = handler;
 		t->neigh_vars[3].strategy = strategy;
 		t->neigh_vars[3].extra1 = dev;
+		/* ReachableTime */
+		t->neigh_vars[4].proc_handler = handler;
+		t->neigh_vars[4].strategy = strategy;
+		t->neigh_vars[4].extra1 = dev;
 	}
 	t->neigh_vars[4].data  = &p->base_reachable_time;
 	t->neigh_vars[5].data  = &p->delay_probe_time;
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:12 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:12 +09:00
@@ -1542,7 +1542,17 @@
 	struct inet6_dev *idev;
 	int ret;
 	
-	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	switch (ctl->ctl_name) {
+	case NET_NEIGH_RETRANS_TIME:
+		ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+		break;
+	case NET_NEIGH_REACHABLE_TIME:
+		ret = proc_dointvec_jiffies(ctl, write,
+					    filp, buffer, lenp, ppos);
+		break;
+	default:
+		ret = -1;
+	}
 
 	if (write && ret == 0 && dev && (idev = in6_dev_get(dev)) != NULL) {
 		idev->tstamp = jiffies;
@@ -1551,6 +1561,36 @@
 	}
 	return ret;
 }
+
+int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name, int nlen,
+				 void __user *oldval, size_t __user *oldlenp,
+				 void __user *newval, size_t newlen,
+				 void **context)
+{
+	struct net_device *dev = ctl->extra1;
+	struct inet6_dev *idev;
+	int ret;
+
+	switch (ctl->ctl_name) {
+	case NET_NEIGH_REACHABLE_TIME:
+		ret = sysctl_jiffies(ctl, name, nlen,
+				     oldval, oldlenp, newval, newlen,
+				     context);
+		break;
+	default:
+		ret = 0;
+	}
+
+	if (newval && newlen && ret > 0 &&
+	    dev && (idev = in6_dev_get(dev)) != NULL) {
+		idev->tstamp = jiffies;
+		inet6_ifinfo_notify(RTM_NEWLINK, idev);
+		in6_dev_put(idev);
+	}
+
+	return ret;
+}
+
 #endif
 
 int __init ndisc_init(struct net_proto_family *ops)
@@ -1584,7 +1624,9 @@
 
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, 
-			      "ipv6", &ndisc_ifinfo_sysctl_change, NULL);
+			      "ipv6",
+			      &ndisc_ifinfo_sysctl_change,
+			      &ndisc_ifinfo_sysctl_strategy);
 #endif
 
 	register_netdevice_notifier(&ndisc_netdev_notifier);

ChangeSet@1.2087, 2005-03-03 14:37:14+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Recompute Reachable Time on change of Base Reachable Time.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:17 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:17 +09:00
@@ -1555,6 +1555,8 @@
 	}
 
 	if (write && ret == 0 && dev && (idev = in6_dev_get(dev)) != NULL) {
+		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
+			idev->nd_parms->reachable_time = neigh_rand_reach_time(idev->nd_parms->base_reachable_time);
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);
 		in6_dev_put(idev);
@@ -1583,6 +1585,8 @@
 
 	if (newval && newlen && ret > 0 &&
 	    dev && (idev = in6_dev_get(dev)) != NULL) {
+		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
+			idev->nd_parms->reachable_time = neigh_rand_reach_time(idev->nd_parms->base_reachable_time);
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);
 		in6_dev_put(idev);

ChangeSet@1.2088, 2005-03-03 14:37:28+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: Add retrans_time_ms and reachable_time_ms sysctls.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt	2005-03-03 16:33:21 +09:00
+++ b/Documentation/filesystems/proc.txt	2005-03-03 16:33:21 +09:00
@@ -1754,18 +1754,25 @@
 
 In the interface directories you'll find the following entries:
 
-base_reachable_time
--------------------
+base_reachable_time, base_reachable_time_ms
+-------------------------------------------
 
 A base  value  used for computing the random reachable time value as specified
 in RFC2461.
 
-retrans_time
-------------
+Expression of base_reachable_time is in seconds.
+Expression of base_reachable_time_ms is in milliseconds.
 
-The time,  expressed  in  jiffies  (1/100 sec), between retransmitted Neighbor
-Solicitation messages.  Used  for  address  resolution  and  to determine if a
-neighbor is unreachable.
+retrans_time, retrans_time_ms
+-----------------------------
+
+The time between retransmitted Neighbor Solicitation messages.
+Used for address resolution and to determine if a neighbor is
+unreachable.
+
+Expression of retrans_time is in 1/100 seconds (for IPv4) or in jiffies
+(for IPv6).
+Expression of retrans_time_ms is in milliseconds.
 
 unres_qlen
 ----------
diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-03-03 16:33:21 +09:00
+++ b/include/linux/sysctl.h	2005-03-03 16:33:21 +09:00
@@ -501,7 +501,10 @@
 	NET_NEIGH_GC_INTERVAL=13,
 	NET_NEIGH_GC_THRESH1=14,
 	NET_NEIGH_GC_THRESH2=15,
-	NET_NEIGH_GC_THRESH3=16
+	NET_NEIGH_GC_THRESH3=16,
+	NET_NEIGH_RETRANS_TIME_MS=17,
+	NET_NEIGH_REACHABLE_TIME_MS=18,
+	__NET_NEIGH_MAX
 };
 
 /* /proc/sys/net/ipx */
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2005-03-03 16:33:21 +09:00
+++ b/net/core/neighbour.c	2005-03-03 16:33:21 +09:00
@@ -2047,7 +2047,7 @@
 
 static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		neigh_vars[17];
+	ctl_table		neigh_vars[__NET_NEIGH_MAX];
 	ctl_table		neigh_dev[2];
 	ctl_table		neigh_neigh_dir[2];
 	ctl_table		neigh_proto_dir[2];
@@ -2170,6 +2170,22 @@
 			.mode		= 0644,
 			.proc_handler	= &proc_dointvec,
 		},
+		{
+			.ctl_name	= NET_NEIGH_RETRANS_TIME_MS,
+			.procname	= "retrans_time_ms",
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec_ms_jiffies,
+			.strategy	= &sysctl_ms_jiffies,
+		},
+		{
+			.ctl_name	= NET_NEIGH_REACHABLE_TIME_MS,
+			.procname	= "base_reachable_time_ms",
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec_ms_jiffies,
+			.strategy	= &sysctl_ms_jiffies,
+		},
 	},
 	.neigh_dev = {
 		{
@@ -2214,16 +2230,6 @@
 	t->neigh_vars[1].data  = &p->ucast_probes;
 	t->neigh_vars[2].data  = &p->app_probes;
 	t->neigh_vars[3].data  = &p->retrans_time;
-	if (handler || strategy) {
-		/* RetransTime */
-		t->neigh_vars[3].proc_handler = handler;
-		t->neigh_vars[3].strategy = strategy;
-		t->neigh_vars[3].extra1 = dev;
-		/* ReachableTime */
-		t->neigh_vars[4].proc_handler = handler;
-		t->neigh_vars[4].strategy = strategy;
-		t->neigh_vars[4].extra1 = dev;
-	}
 	t->neigh_vars[4].data  = &p->base_reachable_time;
 	t->neigh_vars[5].data  = &p->delay_probe_time;
 	t->neigh_vars[6].data  = &p->gc_staletime;
@@ -2233,16 +2239,41 @@
 	t->neigh_vars[10].data = &p->proxy_delay;
 	t->neigh_vars[11].data = &p->locktime;
 
- 	dev_name_source = t->neigh_dev[0].procname;
 	if (dev) {
 		dev_name_source = dev->name;
 		t->neigh_dev[0].ctl_name = dev->ifindex;
-		memset(&t->neigh_vars[12], 0, sizeof(ctl_table));
+		t->neigh_vars[12].procname = NULL;
+		t->neigh_vars[13].procname = NULL;
+		t->neigh_vars[14].procname = NULL;
+		t->neigh_vars[15].procname = NULL;
 	} else {
+ 		dev_name_source = t->neigh_dev[0].procname;
 		t->neigh_vars[12].data = (int *)(p + 1);
 		t->neigh_vars[13].data = (int *)(p + 1) + 1;
 		t->neigh_vars[14].data = (int *)(p + 1) + 2;
 		t->neigh_vars[15].data = (int *)(p + 1) + 3;
+	}
+
+	t->neigh_vars[16].data  = &p->retrans_time;
+	t->neigh_vars[17].data  = &p->base_reachable_time;
+
+	if (handler || strategy) {
+		/* RetransTime */
+		t->neigh_vars[3].proc_handler = handler;
+		t->neigh_vars[3].strategy = strategy;
+		t->neigh_vars[3].extra1 = dev;
+		/* ReachableTime */
+		t->neigh_vars[4].proc_handler = handler;
+		t->neigh_vars[4].strategy = strategy;
+		t->neigh_vars[4].extra1 = dev;
+		/* RetransTime (in milliseconds)*/
+		t->neigh_vars[16].proc_handler = handler;
+		t->neigh_vars[16].strategy = strategy;
+		t->neigh_vars[16].extra1 = dev;
+		/* ReachableTime (in milliseconds) */
+		t->neigh_vars[17].proc_handler = handler;
+		t->neigh_vars[17].strategy = strategy;
+		t->neigh_vars[17].extra1 = dev;
 	}
 
 	dev_name = net_sysctl_strdup(dev_name_source);
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:21 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:21 +09:00
@@ -1550,12 +1550,18 @@
 		ret = proc_dointvec_jiffies(ctl, write,
 					    filp, buffer, lenp, ppos);
 		break;
+	case NET_NEIGH_RETRANS_TIME_MS:
+	case NET_NEIGH_REACHABLE_TIME_MS:
+		ret = proc_dointvec_ms_jiffies(ctl, write,
+					       filp, buffer, lenp, ppos);
+		break;
 	default:
 		ret = -1;
 	}
 
 	if (write && ret == 0 && dev && (idev = in6_dev_get(dev)) != NULL) {
-		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
+		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME ||
+		    ctl->ctl_name == NET_NEIGH_REACHABLE_TIME_MS)
 			idev->nd_parms->reachable_time = neigh_rand_reach_time(idev->nd_parms->base_reachable_time);
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);
@@ -1579,13 +1585,20 @@
 				     oldval, oldlenp, newval, newlen,
 				     context);
 		break;
+	case NET_NEIGH_RETRANS_TIME_MS:
+	case NET_NEIGH_REACHABLE_TIME_MS:
+		 ret = sysctl_ms_jiffies(ctl, name, nlen,
+					 oldval, oldlenp, newval, newlen,
+					 context);
+		 break;
 	default:
 		ret = 0;
 	}
 
 	if (newval && newlen && ret > 0 &&
 	    dev && (idev = in6_dev_get(dev)) != NULL) {
-		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
+		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME ||
+		    ctl->ctl_name == NET_NEIGH_REACHABLE_TIME_MS)
 			idev->nd_parms->reachable_time = neigh_rand_reach_time(idev->nd_parms->base_reachable_time);
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);

ChangeSet@1.2089, 2005-03-03 14:37:40+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Deprecate base_reachable_time and retrans_timer.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt	2005-03-03 16:33:26 +09:00
+++ b/Documentation/filesystems/proc.txt	2005-03-03 16:33:26 +09:00
@@ -1760,7 +1760,7 @@
 A base  value  used for computing the random reachable time value as specified
 in RFC2461.
 
-Expression of base_reachable_time is in seconds.
+Expression of base_reachable_time, which is deprecated, is in seconds.
 Expression of base_reachable_time_ms is in milliseconds.
 
 retrans_time, retrans_time_ms
@@ -1770,8 +1770,8 @@
 Used for address resolution and to determine if a neighbor is
 unreachable.
 
-Expression of retrans_time is in 1/100 seconds (for IPv4) or in jiffies
-(for IPv6).
+Expression of retrans_time, which is deprecated, is in 1/100 seconds (for
+IPv4) or in jiffies (for IPv6).
 Expression of retrans_time_ms is in milliseconds.
 
 unres_qlen
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:26 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:26 +09:00
@@ -1536,12 +1536,35 @@
 };
 
 #ifdef CONFIG_SYSCTL
+static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
+					 const char *func, const char *dev_name)
+{
+	static char warncomm[TASK_COMM_LEN];
+	static int warned;
+	if (strcmp(warncomm, current->comm) && warned < 5) {
+		strcpy(warncomm, current->comm);
+		printk(KERN_WARNING
+			"process `%s' is using deprecated sysctl (%s) "
+			"net.ipv6.neigh.%s.%s; "
+			"Use net.ipv6.neigh.%s.%s_ms "
+			"instead.\n",
+			warncomm, func,
+			dev_name, ctl->procname,
+			dev_name, ctl->procname);
+		warned++;
+	}
+}
+
 int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * filp, void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
 	int ret;
-	
+
+	if (ctl->ctl_name == NET_NEIGH_RETRANS_TIME ||
+	    ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
+		ndisc_warn_deprecated_sysctl(ctl, "syscall", dev ? dev->name : "default");
+
 	switch (ctl->ctl_name) {
 	case NET_NEIGH_RETRANS_TIME:
 		ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
@@ -1578,6 +1601,10 @@
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
 	int ret;
+
+	if (ctl->ctl_name == NET_NEIGH_RETRANS_TIME ||
+	    ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
+		ndisc_warn_deprecated_sysctl(ctl, "procfs", dev ? dev->name : "default");
 
 	switch (ctl->ctl_name) {
 	case NET_NEIGH_REACHABLE_TIME:

ChangeSet@1.2090, 2005-03-03 14:37:53+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ROUTE: Keep cache entries for a while.
 
 GC always removed most cache entries and
 a fresh redirect entry might be removed immideately.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c	2005-03-03 16:33:31 +09:00
+++ b/net/ipv6/ip6_fib.c	2005-03-03 16:33:31 +09:00
@@ -1211,7 +1211,7 @@
 {
 	if (dummy != ~0UL) {
 		spin_lock_bh(&fib6_gc_lock);
-		gc_args.timeout = (int)dummy;
+		gc_args.timeout = dummy ? (int)dummy : ip6_rt_gc_interval;
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:31 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:31 +09:00
@@ -1518,11 +1518,11 @@
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&nd_tbl, dev);
-		fib6_run_gc(0);
+		fib6_run_gc(~0UL);
 		break;
 	case NETDEV_DOWN:
 		neigh_ifdown(&nd_tbl, dev);
-		fib6_run_gc(0);
+		fib6_run_gc(~0UL);
 		break;
 	default:
 		break;
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2005-03-03 16:33:31 +09:00
+++ b/net/ipv6/route.c	2005-03-03 16:33:31 +09:00
@@ -1993,9 +1993,7 @@
 {
 	if (write) {
 		proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
-		if (flush_delay < 0)
-			flush_delay = 0;
-		fib6_run_gc((unsigned long)flush_delay);
+		fib6_run_gc(flush_delay <= 0 ? ~0UL : (unsigned long)flush_delay);
 		return 0;
 	} else
 		return -EINVAL;

ChangeSet@1.2091, 2005-03-03 14:38:06+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Ensure to send redirects.
 
 rt6_lookup() is inappropriate because it cannot lookup
 route to the source node of the original packet if
 we don't have specific route to it.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:35 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:35 +09:00
@@ -1344,10 +1344,9 @@
 
 	ndisc_flow_init(&fl, NDISC_REDIRECT, &saddr_buf, &skb->nh.ipv6h->saddr);
 
-	rt = rt6_lookup(&skb->nh.ipv6h->saddr, NULL, dev->ifindex, 1);
-	if (rt == NULL)
+	dst = ip6_route_output(NULL, &fl);
+	if (dst == NULL)
 		return;
-	dst = &rt->u.dst;
 
 	err = xfrm_lookup(&dst, &fl, NULL, 0);
 	if (err) {

ChangeSet@1.2092, 2005-03-03 14:38:18+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Ensure to send redirects even if we don't know target's lladdr.

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:40 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:40 +09:00
@@ -1332,6 +1332,7 @@
 	int rd_len;
 	int err;
 	int hlen;
+	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 
 	dev = skb->dev;
 
@@ -1368,16 +1369,14 @@
 	}
 
 	if (dev->addr_len) {
-		if (neigh->nud_state&NUD_VALID) {
-			len  += ndisc_opt_addr_space(dev);
-		} else {
-			/* If nexthop is not valid, do not redirect!
-			   We will make it later, when will be sure,
-			   that it is alive.
-			 */
-			dst_release(dst);
-			return;
-		}
+		read_lock_bh(&neigh->lock);
+		if (neigh->nud_state & NUD_VALID) {
+			memcpy(ha_buf, neigh->ha, dev->addr_len);
+			read_unlock_bh(&neigh->lock);
+			ha = ha_buf;
+			len += ndisc_opt_addr_space(dev);
+		} else
+			read_unlock_bh(&neigh->lock);
 	}
 
 	rd_len = min_t(unsigned int,
@@ -1422,8 +1421,8 @@
 	 *	include target_address option
 	 */
 
-	if (dev->addr_len)
-		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, neigh->ha,
+	if (ha)
+		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, ha,
 					     dev->addr_len, dev->type);
 
 	/*

ChangeSet@1.2093, 2005-03-03 14:38:31+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Always add a fragment header after receiving TOO BIG w/ pmtu < 1280.
 
 According to RFC2460, PMTU is set to the IPv6 Minimum Link
 MTU (1280) and a fragment header should always be included
 after a node receiving Too Big message reporting PMTU is
 less than the IPv6 Minimum Link MTU (1280).
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	2005-03-03 16:33:45 +09:00
+++ b/include/linux/ip.h	2005-03-03 16:33:45 +09:00
@@ -152,6 +152,7 @@
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
+#define IPCORK_ALLFRAG	2	/* always fragment (for ipv6 for now) */
 
 static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	2005-03-03 16:33:45 +09:00
+++ b/include/linux/rtnetlink.h	2005-03-03 16:33:45 +09:00
@@ -346,6 +346,7 @@
 #define RTAX_FEATURE_ECN	0x00000001
 #define RTAX_FEATURE_SACK	0x00000002
 #define RTAX_FEATURE_TIMESTAMP	0x00000004
+#define RTAX_FEATURE_ALLFRAG	0x00000008
 
 struct rta_session
 {
diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2005-03-03 16:33:45 +09:00
+++ b/include/net/dst.h	2005-03-03 16:33:45 +09:00
@@ -124,6 +124,15 @@
 	return mtu;
 }
 
+static inline u32
+dst_allfrag(const struct dst_entry *dst)
+{
+	int ret = dst_path_metric(dst, RTAX_FEATURES) & RTAX_FEATURE_ALLFRAG;
+	/* Yes, _exactly_. This is paranoia. */
+	barrier();
+	return ret;
+}
+
 static inline int
 dst_metric_locked(struct dst_entry *dst, int metric)
 {
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2005-03-03 16:33:45 +09:00
+++ b/net/ipv6/ip6_output.c	2005-03-03 16:33:45 +09:00
@@ -147,7 +147,7 @@
 
 int ip6_output(struct sk_buff *skb)
 {
-	if (skb->len > dst_pmtu(skb->dst))
+	if (skb->len > dst_pmtu(skb->dst) || dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -848,6 +848,8 @@
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
+		if (dst_allfrag(&rt->u.dst))
+			inet->cork.flags |= IPCORK_ALLFRAG;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
@@ -899,7 +901,7 @@
 
 	while (length > 0) {
 		/* Check if the remaining data fits into current packet. */
-		copy = mtu - skb->len;
+		copy = (inet->cork.length <= mtu && !(inet->cork.flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - skb->len;
 		if (copy < length)
 			copy = maxfraglen - skb->len;
 
@@ -924,7 +926,7 @@
 			 * we know we need more fragment(s).
 			 */
 			datalen = length + fraggap;
-			if (datalen > mtu - fragheaderlen)
+			if (datalen > (inet->cork.length <= mtu && !(inet->cork.flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen)
 				datalen = maxfraglen - fragheaderlen;
 
 			fraglen = datalen + fragheaderlen;
@@ -1158,6 +1160,7 @@
 	if (np->cork.rt) {
 		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
+		inet->cork.flags &= ~IPCORK_ALLFRAG;
 	}
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 	return err;
@@ -1185,6 +1188,7 @@
 	if (np->cork.rt) {
 		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
+		inet->cork.flags &= ~IPCORK_ALLFRAG;
 	}
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 }
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2005-03-03 16:33:45 +09:00
+++ b/net/ipv6/route.c	2005-03-03 16:33:45 +09:00
@@ -628,8 +628,10 @@
 
 	if (mtu < dst_pmtu(dst) && rt6->rt6i_dst.plen == 128) {
 		rt6->rt6i_flags |= RTF_MODIFIED;
-		if (mtu < IPV6_MIN_MTU)
+		if (mtu < IPV6_MIN_MTU) {
 			mtu = IPV6_MIN_MTU;
+			dst->metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
+		}
 		dst->metrics[RTAX_MTU-1] = mtu;
 	}
 }
@@ -1164,26 +1166,26 @@
 			struct net_device *dev, u32 pmtu)
 {
 	struct rt6_info *rt, *nrt;
-
-	if (pmtu < IPV6_MIN_MTU) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "rt6_pmtu_discovery: invalid MTU value %d\n",
-			       pmtu);
-		/* According to RFC1981, the PMTU is set to the IPv6 minimum
-		   link MTU if the node receives a Packet Too Big message
-		   reporting next-hop MTU that is less than the IPv6 minimum MTU.
-		   */
-		pmtu = IPV6_MIN_MTU;
-	}
+	int allfrag = 0;
 
 	rt = rt6_lookup(daddr, saddr, dev->ifindex, 0);
-
 	if (rt == NULL)
 		return;
 
 	if (pmtu >= dst_pmtu(&rt->u.dst))
 		goto out;
 
+	if (pmtu < IPV6_MIN_MTU) {
+		/*
+		 * According to RFC2460, PMTU is set to the IPv6 Minimum Link 
+		 * MTU (1280) and a fragment header should always be included
+		 * after a node receiving Too Big message reporting PMTU is
+		 * less than the IPv6 Minimum Link MTU.
+		 */
+		pmtu = IPV6_MIN_MTU;
+		allfrag = 1;
+	}
+
 	/* New mtu received -> path was valid.
 	   They are sent only in response to data packets,
 	   so that this nexthop apparently is reachable. --ANK
@@ -1197,6 +1199,8 @@
 	 */
 	if (rt->rt6i_flags & RTF_CACHE) {
 		rt->u.dst.metrics[RTAX_MTU-1] = pmtu;
+		if (allfrag)
+			rt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
 		dst_set_expires(&rt->u.dst, ip6_rt_mtu_expires);
 		rt->rt6i_flags |= RTF_MODIFIED|RTF_EXPIRES;
 		goto out;
@@ -1211,6 +1215,8 @@
 		nrt = rt6_cow(rt, daddr, saddr);
 		if (!nrt->u.dst.error) {
 			nrt->u.dst.metrics[RTAX_MTU-1] = pmtu;
+			if (allfrag)
+				nrt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
 			/* According to RFC 1981, detecting PMTU increase shouldn't be
 			   happened within 5 mins, the recommended timer is 10 mins.
 			   Here this route expiration time is set to ip6_rt_mtu_expires
@@ -1232,6 +1238,8 @@
 		dst_set_expires(&nrt->u.dst, ip6_rt_mtu_expires);
 		nrt->rt6i_flags |= RTF_DYNAMIC|RTF_CACHE|RTF_EXPIRES;
 		nrt->u.dst.metrics[RTAX_MTU-1] = pmtu;
+		if (allfrag)
+			nrt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
 		ip6_ins_rt(nrt, NULL, NULL);
 	}
 

ChangeSet@1.2094, 2005-03-03 14:38:44+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Ensure to use interface hoplimit by default.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/addrconf.h b/include/net/addrconf.h
--- a/include/net/addrconf.h	2005-03-03 16:33:49 +09:00
+++ b/include/net/addrconf.h	2005-03-03 16:33:49 +09:00
@@ -102,6 +102,8 @@
 
 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);
 
+extern int ipv6_get_hoplimit(struct net_device *dev);
+
 /*
  *	anycast prototypes (anycast.c)
  */
diff -Nru a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	2005-03-03 16:33:49 +09:00
+++ b/net/ipv6/icmp.c	2005-03-03 16:33:49 +09:00
@@ -381,6 +381,8 @@
 		hlimit = np->hop_limit;
 	if (hlimit < 0)
 		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+	if (hlimit < 0)
+		hlimit = ipv6_get_hoplimit(dst->dev);
 
 	msg.skb = skb;
 	msg.offset = skb->nh.raw - skb->data;
@@ -467,6 +469,8 @@
 		hlimit = np->hop_limit;
 	if (hlimit < 0)
 		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+	if (hlimit < 0)
+		hlimit = ipv6_get_hoplimit(dst->dev);
 
 	idev = in6_dev_get(skb->dev);
 
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2005-03-03 16:33:49 +09:00
+++ b/net/ipv6/ip6_output.c	2005-03-03 16:33:49 +09:00
@@ -253,6 +253,8 @@
 		hlimit = np->hop_limit;
 	if (hlimit < 0)
 		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+	if (hlimit < 0)
+		hlimit = ipv6_get_hoplimit(dst->dev);
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-03-03 16:33:49 +09:00
+++ b/net/ipv6/ndisc.c	2005-03-03 16:33:49 +09:00
@@ -1128,8 +1128,11 @@
 	if (rt)
 		rt->rt6i_expires = jiffies + (HZ * lifetime);
 
-	if (ra_msg->icmph.icmp6_hop_limit)
+	if (ra_msg->icmph.icmp6_hop_limit) {
 		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
+		if (rt)
+			rt->u.dst.metrics[RTAX_HOPLIMIT-1] = ra_msg->icmph.icmp6_hop_limit;
+	}
 
 	/*
 	 *	Update Reachable Time and Retrans Timer
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2005-03-03 16:33:49 +09:00
+++ b/net/ipv6/raw.c	2005-03-03 16:33:49 +09:00
@@ -756,6 +756,8 @@
 			hlimit = np->hop_limit;
 		if (hlimit < 0)
 			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+		if (hlimit < 0)
+			hlimit = ipv6_get_hoplimit(dst->dev);
 	}
 
 	if (msg->msg_flags&MSG_CONFIRM)
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2005-03-03 16:33:49 +09:00
+++ b/net/ipv6/route.c	2005-03-03 16:33:49 +09:00
@@ -771,7 +771,7 @@
 	return mtu;
 }
 
-static int ipv6_get_hoplimit(struct net_device *dev)
+int ipv6_get_hoplimit(struct net_device *dev)
 {
 	int hoplimit = ipv6_devconf.hop_limit;
 	struct inet6_dev *idev;
@@ -967,15 +967,8 @@
 		}
 	}
 
-	if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0) {
-		if (ipv6_addr_is_multicast(&rt->rt6i_dst.addr))
-			rt->u.dst.metrics[RTAX_HOPLIMIT-1] =
-				IPV6_DEFAULT_MCASTHOPS;
-		else
-			rt->u.dst.metrics[RTAX_HOPLIMIT-1] =
-				ipv6_get_hoplimit(dev);
-	}
-
+	if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
+		rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
 	if (!rt->u.dst.metrics[RTAX_MTU-1])
 		rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
 	if (!rt->u.dst.metrics[RTAX_ADVMSS-1])
@@ -1414,7 +1407,7 @@
 	rt->rt6i_idev = idev;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
-	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = ipv6_get_hoplimit(rt->rt6i_dev);
+	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
 	rt->u.dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2005-03-03 16:33:49 +09:00
+++ b/net/ipv6/udp.c	2005-03-03 16:33:49 +09:00
@@ -811,6 +811,8 @@
 			hlimit = np->hop_limit;
 		if (hlimit < 0)
 			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+		if (hlimit < 0)
+			hlimit = ipv6_get_hoplimit(dst->dev);
 	}
 
 	if (msg->msg_flags&MSG_CONFIRM)

ChangeSet@1.2095, 2005-03-03 14:38:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Unify common functions to compare ipv6 prefixes.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h	2005-03-03 16:33:54 +09:00
+++ b/include/net/ipv6.h	2005-03-03 16:33:54 +09:00
@@ -305,6 +305,32 @@
 		a1->s6_addr32[3] == a2->s6_addr32[3]);
 }
 
+static inline int __ipv6_prefix_equal(const u32 *a1, const u32 *a2,
+				      unsigned int prefixlen)
+{
+	unsigned pdw, pbi;
+
+	/* check complete u32 in prefix */
+	pdw = prefixlen >> 5;
+	if (pdw && memcmp(a1, a2, pdw << 2))
+		return 0;
+
+	/* check incomplete u32 in prefix */
+	pbi = prefixlen & 0x1f;
+	if (pbi && ((a1[pdw] ^ a2[pdw]) & htonl((0xffffffff) << (32 - pbi))))
+		return 0;
+
+	return 1;
+}
+
+static inline int ipv6_prefix_equal(const struct in6_addr *a1,
+				    const struct in6_addr *a2,
+				    unsigned int prefixlen)
+{
+	return __ipv6_prefix_equal(a1->s6_addr32, a2->s6_addr32,
+				   prefixlen);
+}
+
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
 	return ((a->s6_addr32[0] | a->s6_addr32[1] | 
diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c
--- a/net/ipv6/anycast.c	2005-03-03 16:33:54 +09:00
+++ b/net/ipv6/anycast.c	2005-03-03 16:33:54 +09:00
@@ -48,32 +48,6 @@
 /* Big ac list lock for all the sockets */
 static DEFINE_RWLOCK(ipv6_sk_ac_lock);
 
-/* XXX ip6_addr_match() and ip6_onlink() really belong in net/core.c */
-
-static int
-ip6_addr_match(struct in6_addr *addr1, struct in6_addr *addr2, int prefix)
-{
-	__u32	mask;
-	int	i;
-
-	if (prefix > 128 || prefix < 0)
-		return 0;
-	if (prefix == 0)
-		return 1;
-	for (i=0; i<4; ++i) {
-		if (prefix >= 32)
-			mask = ~0;
-		else
-			mask = htonl(~0 << (32 - prefix));
-		if ((addr1->s6_addr32[i] ^ addr2->s6_addr32[i]) & mask)
-			return 0;
-		prefix -= 32;
-		if (prefix <= 0)
-			break;
-	}
-	return 1;
-}
-
 static int
 ip6_onlink(struct in6_addr *addr, struct net_device *dev)
 {
@@ -87,8 +61,8 @@
 	if (idev) {
 		read_lock_bh(&idev->lock);
 		for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
-			onlink = ip6_addr_match(addr, &ifa->addr,
-					ifa->prefix_len);
+			onlink = ipv6_prefix_equal(addr, &ifa->addr,
+						   ifa->prefix_len);
 			if (onlink)
 				break;
 		}
diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c	2005-03-03 16:33:54 +09:00
+++ b/net/ipv6/ip6_fib.c	2005-03-03 16:33:54 +09:00
@@ -117,36 +117,6 @@
  */
 
 /*
- *	compare "prefix length" bits of an address
- */
-
-static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
-{
-	__u32 *a1 = token1;
-	__u32 *a2 = token2;
-	int pdw;
-	int pbi;
-
-	pdw = prefixlen >> 5;	  /* num of whole __u32 in prefix */
-	pbi = prefixlen &  0x1f;  /* num of bits in incomplete u32 in prefix */
-
-	if (pdw)
-		if (memcmp(a1, a2, pdw << 2))
-			return 0;
-
-	if (pbi) {
-		__u32 mask;
-
-		mask = htonl((0xffffffff) << (32 - pbi));
-
-		if ((a1[pdw] ^ a2[pdw]) & mask)
-			return 0;
-	}
-
-	return 1;
-}
-
-/*
  *	test bit
  */
 
@@ -261,7 +231,7 @@
 		 *	Prefix match
 		 */
 		if (plen < fn->fn_bit ||
-		    !addr_match(&key->addr, addr, fn->fn_bit))
+		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit))
 			goto insert_above;
 		
 		/*
@@ -667,7 +637,7 @@
 			key = (struct rt6key *) ((u8 *) fn->leaf +
 						 args->offset);
 
-			if (addr_match(&key->addr, args->addr, key->plen))
+			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen))
 				return fn;
 		}
 
@@ -718,7 +688,7 @@
 		 *	Prefix match
 		 */
 		if (plen < fn->fn_bit ||
-		    !addr_match(&key->addr, addr, fn->fn_bit))
+		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit))
 			return NULL;
 
 		if (plen == fn->fn_bit)

ChangeSet@1.2096, 2005-03-03 14:39:10+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ADDRCONF: Update prefix route on address deletion.
 
 We did not delete prefix route on deletion of corresponding
 permanent address while we add prefix route on addition of
 permanent address. This was confusing.
 With this changeset, we purge prefix route or convert it to
 dynamic one, if appropriate.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2005-03-03 16:33:59 +09:00
+++ b/net/ipv6/addrconf.c	2005-03-03 16:33:59 +09:00
@@ -591,6 +591,8 @@
 	struct inet6_ifaddr *ifa, **ifap;
 	struct inet6_dev *idev = ifp->idev;
 	int hash;
+	int deleted = 0, onlink = 0;
+	unsigned long expires = jiffies;
 
 	hash = ipv6_addr_hash(&ifp->addr);
 
@@ -633,7 +635,31 @@
 			*ifap = ifa->if_next;
 			__in6_ifa_put(ifp);
 			ifa->if_next = NULL;
-			break;
+			if (!(ifp->flags & IFA_F_PERMANENT) || onlink > 0)
+				break;
+			deleted = 1;
+		} else if (ifp->flags & IFA_F_PERMANENT) {
+			if (ipv6_prefix_equal(&ifa->addr, &ifp->addr,
+					      ifp->prefix_len)) {
+				if (ifa->flags & IFA_F_PERMANENT) {
+					onlink = 1;
+					if (deleted)
+						break;
+				} else {
+					unsigned long lifetime;
+
+					if (!onlink)
+						onlink = -1;
+
+					spin_lock(&ifa->lock);
+					lifetime = min_t(unsigned long,
+							 ifa->valid_lft, 0x7fffffffUL/HZ);
+					if (time_before(expires,
+							ifa->tstamp + lifetime * HZ))
+						expires = ifa->tstamp + lifetime * HZ;
+					spin_unlock(&ifa->lock);
+				}
+			}
 		}
 	}
 	write_unlock_bh(&idev->lock);
@@ -643,6 +669,40 @@
 	notifier_call_chain(&inet6addr_chain,NETDEV_DOWN,ifp);
 
 	addrconf_del_timer(ifp);
+
+	/*
+	 * Purge or update corresponding prefix
+	 *
+	 * 1) we don't purge prefix here if address was not permanent.
+	 *    prefix is managed by its own lifetime.
+	 * 2) if there're no addresses, delete prefix.
+	 * 3) if there're still other permanent address(es),
+	 *    corresponding prefix is still permanent.
+	 * 4) otherwise, update prefix lifetime to the
+	 *    longest valid lifetime among the corresponding
+	 *    addresses on the device.
+	 *    Note: subsequent RA will update lifetime.
+	 *
+	 * --yoshfuji
+	 */
+	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
+		struct in6_addr prefix;
+		struct rt6_info *rt;
+
+		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
+		rt = rt6_lookup(&prefix, NULL, ifp->idev->dev->ifindex, 1);
+
+		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+			if (onlink == 0) {
+				ip6_del_rt(rt, NULL, NULL);
+				rt = NULL;
+			} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
+				rt->rt6i_expires = expires;
+				rt->rt6i_flags |= RTF_EXPIRES;
+			}
+		}
+		dst_release(&rt->u.dst);
+	}
 
 	in6_ifa_put(ifp);
 }

ChangeSet@1.2097, 2005-03-03 14:39:22+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Mature enough, no longer EXPERIMENTAL.
 
 Now we can pass IPv6 Ready Logo <http://www.ipv6ready.org>
 Phase 1 and Phase 2 Self Tests.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/Kconfig b/net/Kconfig
--- a/net/Kconfig	2005-03-03 16:34:03 +09:00
+++ b/net/Kconfig	2005-03-03 16:34:03 +09:00
@@ -107,27 +107,22 @@
 
 #   IPv6 as module will cause a CRASH if you try to unload it
 config IPV6
-	tristate "The IPv6 protocol (EXPERIMENTAL)"
-	depends on INET && EXPERIMENTAL
+	tristate "The IPv6 protocol"
+	depends on INET
 	select CRYPTO if IPV6_PRIVACY
 	select CRYPTO_MD5 if IPV6_PRIVACY
 	---help---
-	  This is experimental support for the IP version 6 (formerly called
-	  IPng "IP next generation").  You will still be able to do
-	  regular IPv4 networking as well.
+	  This is complemental support for the IP version 6.
+	  You will still be able to do traditional IPv4 networking as well.
 
-	  Features of this new protocol include: expanded address space,
-	  authentication and privacy, and seamless interoperability with the
-	  current version of IP (IP version 4). For general information about
-	  IPv6, see <http://playground.sun.com/pub/ipng/html/ipng-main.html>;
-	  for specific information about IPv6 under Linux read the HOWTO at
-	  <http://www.bieringer.de/linux/IPv6/> and the file net/ipv6/README
-	  in the kernel source.
+	  For general information about IPv6, see
+	  <http://playground.sun.com/pub/ipng/html/ipng-main.html>.
+	  For Linux IPv6 development information, see <http://www.linux-ipv6.org>.
+	  For specific information about IPv6 under Linux, read the HOWTO at
+	  <http://www.bieringer.de/linux/IPv6/>.
 
 	  To compile this protocol support as a module, choose M here: the 
 	  module will be called ipv6.
-
-	  It is safe to say N here for now.
 
 source "net/ipv6/Kconfig"
 
diff -Nru a/net/ipv6/README b/net/ipv6/README
--- a/net/ipv6/README	2005-03-03 16:34:03 +09:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,8 +0,0 @@
-To join in the work on Linux IPv6 send mail to:
-
-        majordomo@oss.sgi.com
-
-and in the body of the message include:
-
-subscribe netdev
-
diff -Nru a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
--- a/net/ipv6/netfilter/Kconfig	2005-03-03 16:34:03 +09:00
+++ b/net/ipv6/netfilter/Kconfig	2005-03-03 16:34:03 +09:00
@@ -2,8 +2,8 @@
 # IP netfilter configuration
 #
 
-menu "IPv6: Netfilter Configuration"
-	depends on INET && IPV6 && NETFILTER
+menu "IPv6: Netfilter Configuration (EXPERIMENTAL)"
+	depends on INET && IPV6 && NETFILTER && EXPERIMENTAL
 
 #tristate 'Connection tracking (required for masq/NAT)' CONFIG_IP6_NF_CONNTRACK
 #if [ "$CONFIG_IP6_NF_CONNTRACK" != "n" ]; then

ChangeSet@1.2098, 2005-03-03 14:39:35+09:00, yoshfuji@linux-ipv6.org
 [NET] Don't use magic number for sysctl table definition.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-03-03 16:34:08 +09:00
+++ b/include/linux/sysctl.h	2005-03-03 16:34:08 +09:00
@@ -398,6 +398,7 @@
 	NET_IPV4_CONF_FORCE_IGMP_VERSION=17,
 	NET_IPV4_CONF_ARP_ANNOUNCE=18,
 	NET_IPV4_CONF_ARP_IGNORE=19,
+	__NET_IPV4_CONF_MAX
 };
 
 /* /proc/sys/net/ipv4/netfilter */
@@ -476,7 +477,8 @@
 	NET_IPV6_REGEN_MAX_RETRY=14,
 	NET_IPV6_MAX_DESYNC_FACTOR=15,
 	NET_IPV6_MAX_ADDRESSES=16,
-	NET_IPV6_FORCE_MLD_VERSION=17
+	NET_IPV6_FORCE_MLD_VERSION=17,
+	__NET_IPV6_MAX
 };
 
 /* /proc/sys/net/ipv6/icmp */
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2005-03-03 16:34:08 +09:00
+++ b/net/ipv4/devinet.c	2005-03-03 16:34:08 +09:00
@@ -1212,7 +1212,7 @@
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		devinet_vars[20];
+	ctl_table		devinet_vars[__NET_IPV4_CONF_MAX];
 	ctl_table		devinet_dev[2];
 	ctl_table		devinet_conf_dir[2];
 	ctl_table		devinet_proto_dir[2];
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2005-03-03 16:34:08 +09:00
+++ b/net/ipv6/addrconf.c	2005-03-03 16:34:08 +09:00
@@ -3212,7 +3212,7 @@
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
-	ctl_table addrconf_vars[18];
+	ctl_table addrconf_vars[__NET_IPV6_MAX];
 	ctl_table addrconf_dev[2];
 	ctl_table addrconf_conf_dir[2];
 	ctl_table addrconf_proto_dir[2];

 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
