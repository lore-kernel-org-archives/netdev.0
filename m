From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 8/8] net/ipv6/addrconf.c: Checkpatch cleanups
Date: Sun,  1 Apr 2012 19:49:08 +0200
Message-ID: <1333302548-9187-8-git-send-email-eldad@fogrefinery.com>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/ipv6/addrconf.c:340: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
net/ipv6/addrconf.c:342: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:444: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:1337: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
net/ipv6/addrconf.c:1526: ERROR: "(foo*)" should be "(foo *)"
net/ipv6/addrconf.c:1671: ERROR: open brace '{' following function declarations go on the next line
net/ipv6/addrconf.c:1914: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:2368: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:2370: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:2416: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:2437: ERROR: "foo    * bar" should be "foo    *bar"
net/ipv6/addrconf.c:2573: ERROR: "foo * bar" should be "foo *bar"
net/ipv6/addrconf.c:3797: ERROR: "foo* bar" should be "foo *bar"

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/addrconf.c |   25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6a3bb60..0031f05 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -336,10 +336,9 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 	snmp6_free_dev(idev);
 	kfree_rcu(idev, rcu);
 }
-
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 
-static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
+static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
 
@@ -441,7 +440,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	return ndev;
 }
 
-static struct inet6_dev * ipv6_find_idev(struct net_device *dev)
+static struct inet6_dev *ipv6_find_idev(struct net_device *dev)
 {
 	struct inet6_dev *idev;
 
@@ -1333,7 +1332,6 @@ int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev)
 	rcu_read_unlock();
 	return onlink;
 }
-
 EXPORT_SYMBOL(ipv6_chk_prefix);
 
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
@@ -1523,7 +1521,7 @@ static int addrconf_ifid_arcnet(u8 *eui, struct net_device *dev)
 	if (dev->addr_len != ARCNET_ALEN)
 		return -1;
 	memset(eui, 0, 7);
-	eui[7] = *(u8*)dev->dev_addr;
+	eui[7] = *(u8 *)dev->dev_addr;
 	return 0;
 }
 
@@ -1668,7 +1666,8 @@ out:
 	in6_dev_put(idev);
 }
 
-static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr) {
+static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr)
+{
 	int ret = 0;
 
 	if (tmpaddr && memcmp(idev->rndid, &tmpaddr->s6_addr[8], 8) == 0)
@@ -1911,7 +1910,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	/* Try to figure out our local address for this prefix */
 
 	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
-		struct inet6_ifaddr * ifp;
+		struct inet6_ifaddr *ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
 
@@ -2365,9 +2364,9 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	}
 
 	for_each_netdev(net, dev) {
-		struct in_device * in_dev = __in_dev_get_rtnl(dev);
+		struct in_device *in_dev = __in_dev_get_rtnl(dev);
 		if (in_dev && (dev->flags & IFF_UP)) {
-			struct in_ifaddr * ifa;
+			struct in_ifaddr *ifa;
 
 			int flag = scope;
 
@@ -2413,7 +2412,7 @@ static void init_loopback(struct net_device *dev)
 
 static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr *addr)
 {
-	struct inet6_ifaddr * ifp;
+	struct inet6_ifaddr *ifp;
 	u32 addr_flags = IFA_F_PERMANENT;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
@@ -2434,7 +2433,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 static void addrconf_dev_config(struct net_device *dev)
 {
 	struct in6_addr addr;
-	struct inet6_dev    * idev;
+	struct inet6_dev *idev;
 
 	ASSERT_RTNL();
 
@@ -2570,7 +2569,7 @@ static void addrconf_ip6_tnl_config(struct net_device *dev)
 }
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
-			   void * data)
+			   void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct inet6_dev *idev = __in6_dev_get(dev);
@@ -3794,7 +3793,7 @@ static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	return inet6_dump_addr(skb, cb, type);
 }
 
-static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr* nlh,
+static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 			     void *arg)
 {
 	struct net *net = sock_net(in_skb->sk);
-- 
1.7.9.5
