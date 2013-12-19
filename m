From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH 4/5] bridge: change "foo* bar" to "foo *bar"
Date: Thu, 19 Dec 2013 13:28:13 +0800
Message-ID: <1387430894-11220-5-git-send-email-tanxiaojun@huawei.com>
References: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bart.de.schuymer@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44507 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab3LSFap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:30:45 -0500
In-Reply-To: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"foo * bar" should be "foo *bar".

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 net/bridge/br_netfilter.c |  2 +-
 net/bridge/br_sysfs_if.c  | 18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 80cad2c..b008c59 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1001,7 +1001,7 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 #ifdef CONFIG_SYSCTL
 static
 int brnf_sysctl_call_tables(struct ctl_table *ctl, int write,
-			    void __user * buffer, size_t * lenp, loff_t * ppos)
+			    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int ret;
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 1549b26..dd595bd 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -209,21 +209,21 @@ static const struct brport_attribute *brport_attrs[] = {
 #define to_brport_attr(_at) container_of(_at, struct brport_attribute, attr)
 #define to_brport(obj)	container_of(obj, struct net_bridge_port, kobj)
 
-static ssize_t brport_show(struct kobject * kobj,
-			   struct attribute * attr, char * buf)
+static ssize_t brport_show(struct kobject *kobj,
+			   struct attribute *attr, char *buf)
 {
-	struct brport_attribute * brport_attr = to_brport_attr(attr);
-	struct net_bridge_port * p = to_brport(kobj);
+	struct brport_attribute *brport_attr = to_brport_attr(attr);
+	struct net_bridge_port *p = to_brport(kobj);
 
 	return brport_attr->show(p, buf);
 }
 
-static ssize_t brport_store(struct kobject * kobj,
-			    struct attribute * attr,
-			    const char * buf, size_t count)
+static ssize_t brport_store(struct kobject *kobj,
+			    struct attribute *attr,
+			    const char *buf, size_t count)
 {
-	struct brport_attribute * brport_attr = to_brport_attr(attr);
-	struct net_bridge_port * p = to_brport(kobj);
+	struct brport_attribute *brport_attr = to_brport_attr(attr);
+	struct net_bridge_port *p = to_brport(kobj);
 	ssize_t ret = -EINVAL;
 	char *endp;
 	unsigned long val;
-- 
1.8.0
