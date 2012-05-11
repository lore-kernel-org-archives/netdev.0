From: Cristian Chilipirea <cristian.chilipirea@gmail.com>
Subject: [PATCH] Net ipv6: Fixed checkpatch errors
Date: Fri, 11 May 2012 19:55:00 +0300
Message-ID: <1336755300-6821-1-git-send-email-cristian.chilipirea@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel.baluta@gmail.com,
	Cristian Chilipirea <cristian.chilipirea@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed all of ERROR "foo* bar" should be "foo *bar"

Signed-off-by: Cristian Chilipirea <cristian.chilipirea@gmail.com>
---
 net/ipv6/addrconf.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)
 mode change 100644 => 100755 net/ipv6/addrconf.c

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
old mode 100644
new mode 100644
index 7d5cb97..9dbc266
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -339,7 +339,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 
-static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
+static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
 
@@ -441,7 +441,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	return ndev;
 }
 
-static struct inet6_dev * ipv6_find_idev(struct net_device *dev)
+static struct inet6_dev *ipv6_find_idev(struct net_device *dev)
 {
 	struct inet6_dev *idev;
 
@@ -1522,7 +1522,7 @@ static int addrconf_ifid_arcnet(u8 *eui, struct net_device *dev)
 	if (dev->addr_len != ARCNET_ALEN)
 		return -1;
 	memset(eui, 0, 7);
-	eui[7] = *(u8*)dev->dev_addr;
+	eui[7] = *(u8 *)dev->dev_addr;
 	return 0;
 }
 
@@ -1667,7 +1667,8 @@ out:
 	in6_dev_put(idev);
 }
 
-static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr) {
+static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr)
+{
 	int ret = 0;
 
 	if (tmpaddr && memcmp(idev->rndid, &tmpaddr->s6_addr[8], 8) == 0)
@@ -1908,7 +1909,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	/* Try to figure out our local address for this prefix */
 
 	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
-		struct inet6_ifaddr * ifp;
+		struct inet6_ifaddr *ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
 
@@ -2362,9 +2363,9 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	}
 
 	for_each_netdev(net, dev) {
-		struct in_device * in_dev = __in_dev_get_rtnl(dev);
+		struct in_device *in_dev = __in_dev_get_rtnl(dev);
 		if (in_dev && (dev->flags & IFF_UP)) {
-			struct in_ifaddr * ifa;
+			struct in_ifaddr *ifa;
 
 			int flag = scope;
 
@@ -2410,7 +2411,7 @@ static void init_loopback(struct net_device *dev)
 
 static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr *addr)
 {
-	struct inet6_ifaddr * ifp;
+	struct inet6_ifaddr *ifp;
 	u32 addr_flags = IFA_F_PERMANENT;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
@@ -2431,7 +2432,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 static void addrconf_dev_config(struct net_device *dev)
 {
 	struct in6_addr addr;
-	struct inet6_dev    * idev;
+	struct inet6_dev    *idev;
 
 	ASSERT_RTNL();
 
@@ -2567,7 +2568,7 @@ static void addrconf_ip6_tnl_config(struct net_device *dev)
 }
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
-			   void * data)
+			   void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct inet6_dev *idev = __in6_dev_get(dev);
@@ -3791,7 +3792,7 @@ static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	return inet6_dump_addr(skb, cb, type);
 }
 
-static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr* nlh,
+static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 			     void *arg)
 {
 	struct net *net = sock_net(in_skb->sk);
-- 
1.7.5.4
