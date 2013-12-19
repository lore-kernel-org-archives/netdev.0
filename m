From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH 3/5] bridge: add space before '(/{', after ',', etc.
Date: Thu, 19 Dec 2013 13:28:12 +0800
Message-ID: <1387430894-11220-4-git-send-email-tanxiaojun@huawei.com>
References: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bart.de.schuymer@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45607 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab3LSFbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:31:55 -0500
In-Reply-To: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spaces required before the open parenthesis '(', before the open
brace '{', after that ',' and around that '?/:'.

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 net/bridge/br_ioctl.c           |  2 +-
 net/bridge/br_private.h         |  2 +-
 net/bridge/br_stp_timer.c       |  2 +-
 net/bridge/br_sysfs_if.c        |  2 +-
 net/bridge/netfilter/ebt_log.c  |  2 +-
 net/bridge/netfilter/ebt_snat.c |  2 +-
 net/bridge/netfilter/ebtables.c | 12 ++++++------
 7 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index cd8c3a4..a9a4a1b 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -381,7 +381,7 @@ int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct net_bridge *br = netdev_priv(dev);
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCDEVPRIVATE:
 		return old_dev_ioctl(dev, rq, cmd);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 045d56e..2e77d92 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -721,7 +721,7 @@ void br_netfilter_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
 #else
 #define br_netfilter_init()	(0)
-#define br_netfilter_fini()	do { } while(0)
+#define br_netfilter_fini()	do { } while (0)
 #define br_netfilter_rtable_init(x)
 #endif
 
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 950663d..558c46d 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -110,7 +110,7 @@ static void br_tcn_timer_expired(unsigned long arg)
 	if (!br_is_root_bridge(br) && (br->dev->flags & IFF_UP)) {
 		br_transmit_tcn(br);
 
-		mod_timer(&br->tcn_timer,jiffies + br->bridge_hello_time);
+		mod_timer(&br->tcn_timer, jiffies + br->bridge_hello_time);
 	}
 	spin_unlock(&br->lock);
 }
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 2a2cdb7..1549b26 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -26,7 +26,7 @@ struct brport_attribute {
 	int (*store)(struct net_bridge_port *, unsigned long);
 };
 
-#define BRPORT_ATTR(_name,_mode,_show,_store)		        \
+#define BRPORT_ATTR(_name, _mode, _show, _store)		\
 const struct brport_attribute brport_attr_##_name = { 	        \
 	.attr = {.name = __stringify(_name), 			\
 		 .mode = _mode },				\
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 19c37a4..5322a36 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -96,7 +96,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 		bitmask = NF_LOG_MASK;
 
 	if ((bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
-	   htons(ETH_P_IP)){
+	   htons(ETH_P_IP)) {
 		const struct iphdr *ih;
 		struct iphdr _iph;
 
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index f8f0bd1..0f6b118 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -35,7 +35,7 @@ ebt_snat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 			return EBT_DROP;
 		if (ap->ar_hln != ETH_ALEN)
 			goto out;
-		if (skb_store_bits(skb, sizeof(_ah), info->mac,ETH_ALEN))
+		if (skb_store_bits(skb, sizeof(_ah), info->mac, ETH_ALEN))
 			return EBT_DROP;
 	}
 out:
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 09d16d7..185aa9c 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -121,7 +121,7 @@ ebt_dev_check(const char *entry, const struct net_device *device)
 	return devname[i] != entry[i] && entry[i] != 1;
 }
 
-#define FWINV2(bool,invflg) ((bool) ^ !!(e->invflags & invflg))
+#define FWINV2(bool, invflg) ((bool) ^ !!(e->invflags & invflg))
 /* process standard matches */
 static inline int
 ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
@@ -1441,7 +1441,7 @@ static int copy_everything_to_user(struct ebt_table *t, void __user *user,
 		return -EFAULT;
 
 	if (*len != sizeof(struct ebt_replace) + entries_size +
-	   (tmp.num_counters? nentries * sizeof(struct ebt_counter): 0))
+	   (tmp.num_counters ? nentries * sizeof(struct ebt_counter) : 0))
 		return -EINVAL;
 
 	if (tmp.nentries != nentries) {
@@ -1477,7 +1477,7 @@ static int do_ebt_set_ctl(struct sock *sk,
 	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	switch(cmd) {
+	switch (cmd) {
 	case EBT_SO_SET_ENTRIES:
 		ret = do_replace(net, user, len);
 		break;
@@ -1507,10 +1507,10 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	if (!t)
 		return ret;
 
-	switch(cmd) {
+	switch (cmd) {
 	case EBT_SO_GET_INFO:
 	case EBT_SO_GET_INIT_INFO:
-		if (*len != sizeof(struct ebt_replace)){
+		if (*len != sizeof(struct ebt_replace)) {
 			ret = -EINVAL;
 			mutex_unlock(&ebt_mutex);
 			break;
@@ -1525,7 +1525,7 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			tmp.valid_hooks = t->table->valid_hooks;
 		}
 		mutex_unlock(&ebt_mutex);
-		if (copy_to_user(user, &tmp, *len) != 0){
+		if (copy_to_user(user, &tmp, *len) != 0) {
 			BUGPRINT("c2u Didn't work\n");
 			ret = -EFAULT;
 			break;
-- 
1.8.0
