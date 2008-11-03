From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 3/4] nets: clean up net/ipv4/devinet.c
Date: Mon, 3 Nov 2008 18:41:51 +0800
Message-ID: <20081103104151.GD19058@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com> <20081103082002.GG14553@ubuntu> <20081103.002808.142907024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:61787 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755037AbYKCKll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 05:41:41 -0500
Content-Disposition: inline
In-Reply-To: <20081103.002808.142907024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[PATCH 3/4] nets: clean up net/ipv4/devinet.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/devinet.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0bff576..309997e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1101,7 +1101,7 @@ out:
 }
 
 static struct notifier_block ip_netdev_notifier = {
-	.notifier_call =inetdev_event,
+	.notifier_call = inetdev_event,
 };
 
 static inline size_t inet_nlmsg_size(void)
@@ -1188,7 +1188,7 @@ done:
 	return skb->len;
 }
 
-static void rtmsg_ifa(int event, struct in_ifaddr* ifa, struct nlmsghdr *nlh,
+static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 		      u32 pid)
 {
 	struct sk_buff *skb;
@@ -1255,7 +1255,7 @@ static void inet_forward_change(struct net *net)
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
-			     struct file* filp, void __user *buffer,
+			     struct file *filp, void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
 {
 	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
@@ -1327,7 +1327,7 @@ static int devinet_conf_sysctl(ctl_table *table,
 }
 
 static int devinet_sysctl_forward(ctl_table *ctl, int write,
-				  struct file* filp, void __user *buffer,
+				  struct file *filp, void __user *buffer,
 				  size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
@@ -1356,7 +1356,7 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 }
 
 int ipv4_doint_and_flush(ctl_table *ctl, int write,
-			 struct file* filp, void __user *buffer,
+			 struct file *filp, void __user *buffer,
 			 size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
-- 
1.5.6.3

