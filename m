From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 6/22]: Add rtattr_strlcpy, use it where appropriate
Date: Mon, 10 Jan 2005 20:37:52 +0100
Message-ID: <41E2D990.6040406@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000600010406060406060801"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000600010406060406060801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------000600010406060406060801
Content-Type: text/x-patch;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="06.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 22:53:27+01:00 kaber@coreworks.de 
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_api.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +3 -2
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +3 -2
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +7 -18
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/fib_rules.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +1 -2
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/devinet.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/decnet/dn_rules.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +1 -2
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/decnet/dn_dev.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/core/rtnetlink.c
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +20 -14
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/pkt_cls.h
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +1 -7
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/linux/rtnetlink.h
#   2005/01/09 22:53:18+01:00 kaber@coreworks.de +1 -0
#   [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
#   
#   Add rtattr_strlcpy to handle unterminated strings. The destination
#   is nulled out entirely to avoid possible leaks when dumping. The
#   return value can be checked for >= size to detect truncated strings.
#   Currently strings equal to the size of the destination are accepted
#   everywhere even if not null-terminated. Sometimes they are silently
#   truncated, sometimes the unterminated string is used.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	2005-01-10 06:22:06 +01:00
+++ b/include/linux/rtnetlink.h	2005-01-10 06:22:06 +01:00
@@ -748,6 +748,7 @@
 
 #include <linux/config.h>
 
+extern size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size);
 static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
 {
 	int len = strlen(str) + 1;
diff -Nru a/include/net/pkt_cls.h b/include/net/pkt_cls.h
--- a/include/net/pkt_cls.h	2005-01-10 06:22:06 +01:00
+++ b/include/net/pkt_cls.h	2005-01-10 06:22:06 +01:00
@@ -148,14 +148,8 @@
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
 {
-	if (RTA_PAYLOAD(indev_tlv) >= IFNAMSIZ) {
-		printk("cls: bad indev name %s\n", (char *) RTA_DATA(indev_tlv));
+	if (rtattr_strlcpy(indev, indev_tlv, IFNAMSIZ) >= IFNAMSIZ)
 		return -EINVAL;
-	}
-
-	memset(indev, 0, IFNAMSIZ);
-	sprintf(indev, "%s", (char *) RTA_DATA(indev_tlv));
-
 	return 0;
 }
 
diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	2005-01-10 06:22:06 +01:00
+++ b/net/core/rtnetlink.c	2005-01-10 06:22:06 +01:00
@@ -119,6 +119,21 @@
 	memcpy(RTA_DATA(rta), data, attrlen);
 }
 
+size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size)
+{
+	size_t ret = RTA_PAYLOAD(rta);
+	char *src = RTA_DATA(rta);
+
+	if (ret > 0 && src[ret - 1] == '\0')
+		ret--;
+	if (size > 0) {
+		size_t len = (ret >= size) ? size - 1 : ret;
+		memset(dest, 0, size);
+		memcpy(dest, src, len);
+	}
+	return ret;
+}
+
 int rtnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, int echo)
 {
 	int err = 0;
@@ -272,13 +287,9 @@
 	else if (ida[IFLA_IFNAME - 1]) {
 		char ifname[IFNAMSIZ];
 
-		if (RTA_PAYLOAD(ida[IFLA_IFNAME - 1]) > RTA_ALIGN(sizeof(ifname)))
+		if (rtattr_strlcpy(ifname, ida[IFLA_IFNAME - 1],
+		                   IFNAMSIZ) >= IFNAMSIZ)
 			return -EINVAL;
-
-		memset(ifname, 0, sizeof(ifname));
-		memcpy(ifname, RTA_DATA(ida[IFLA_IFNAME - 1]),
-			RTA_PAYLOAD(ida[IFLA_IFNAME - 1]));
-		ifname[IFNAMSIZ - 1] = '\0';
 		dev = dev_get_by_name(ifname);
 	} else
 		return -EINVAL;
@@ -376,16 +387,10 @@
 	if (ifm->ifi_index >= 0 && ida[IFLA_IFNAME - 1]) {
 		char ifname[IFNAMSIZ];
 
-		if (RTA_PAYLOAD(ida[IFLA_IFNAME - 1]) > RTA_ALIGN(sizeof(ifname)))
+		if (rtattr_strlcpy(ifname, ida[IFLA_IFNAME - 1],
+		                   IFNAMSIZ) >= IFNAMSIZ)
 			goto out;
-
-		memset(ifname, 0, sizeof(ifname));
-		memcpy(ifname, RTA_DATA(ida[IFLA_IFNAME - 1]),
-			RTA_PAYLOAD(ida[IFLA_IFNAME - 1]));
-		ifname[IFNAMSIZ - 1] = '\0';
-
 		err = dev_change_name(dev, ifname);
-
 		if (err)
 			goto out;
 	}
@@ -690,6 +695,7 @@
 }
 
 EXPORT_SYMBOL(__rta_fill);
+EXPORT_SYMBOL(rtattr_strlcpy);
 EXPORT_SYMBOL(rtattr_parse);
 EXPORT_SYMBOL(rtnetlink_dump_ifinfo);
 EXPORT_SYMBOL(rtnetlink_links);
diff -Nru a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
--- a/net/decnet/dn_dev.c	2005-01-10 06:22:06 +01:00
+++ b/net/decnet/dn_dev.c	2005-01-10 06:22:06 +01:00
@@ -705,7 +705,7 @@
 	ifa->ifa_scope = ifm->ifa_scope;
 	ifa->ifa_dev = dn_db;
 	if (rta[IFA_LABEL-1])
-		memcpy(ifa->ifa_label, RTA_DATA(rta[IFA_LABEL-1]), IFNAMSIZ);
+		rtattr_strlcpy(ifa->ifa_label, rta[IFA_LABEL-1], IFNAMSIZ);
 	else
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 
diff -Nru a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
--- a/net/decnet/dn_rules.c	2005-01-10 06:22:06 +01:00
+++ b/net/decnet/dn_rules.c	2005-01-10 06:22:06 +01:00
@@ -170,8 +170,7 @@
 	new_r->r_table = table_id;
 	if (rta[RTA_IIF-1]) {
 		struct net_device *dev;
-		memcpy(new_r->r_ifname, RTA_DATA(rta[RTA_IIF-1]), IFNAMSIZ);
-		new_r->r_ifname[IFNAMSIZ-1] = 0;
+		rtattr_strlcpy(new_r->r_ifname, rta[RTA_IIF-1], IFNAMSIZ);
 		new_r->r_ifindex = -1;
 		dev = dev_get_by_name(new_r->r_ifname);
 		if (dev) {
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2005-01-10 06:22:06 +01:00
+++ b/net/ipv4/devinet.c	2005-01-10 06:22:06 +01:00
@@ -456,7 +456,7 @@
 	in_dev_hold(in_dev);
 	ifa->ifa_dev   = in_dev;
 	if (rta[IFA_LABEL - 1])
-		memcpy(ifa->ifa_label, RTA_DATA(rta[IFA_LABEL - 1]), IFNAMSIZ);
+		rtattr_strlcpy(ifa->ifa_label, rta[IFA_LABEL - 1], IFNAMSIZ);
 	else
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 
diff -Nru a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
--- a/net/ipv4/fib_rules.c	2005-01-10 06:22:06 +01:00
+++ b/net/ipv4/fib_rules.c	2005-01-10 06:22:06 +01:00
@@ -209,8 +209,7 @@
 	new_r->r_table = table_id;
 	if (rta[RTA_IIF-1]) {
 		struct net_device *dev;
-		memcpy(new_r->r_ifname, RTA_DATA(rta[RTA_IIF-1]), IFNAMSIZ);
-		new_r->r_ifname[IFNAMSIZ-1] = 0;
+		rtattr_strlcpy(new_r->r_ifname, rta[RTA_IIF-1], IFNAMSIZ);
 		new_r->r_ifindex = -1;
 		dev = __dev_get_by_name(new_r->r_ifname);
 		if (dev)
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:22:06 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:22:06 +01:00
@@ -272,7 +272,7 @@
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
-	char act_name[4 + IFNAMSIZ + 1];
+	char act_name[IFNAMSIZ];
 	struct rtattr *tb[TCA_ACT_MAX+1];
 	struct rtattr *kind;
 
@@ -284,12 +284,9 @@
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
 		if (kind != NULL) {
-			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-			if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-				printk("Action %s bad\n",
-				        (char*)RTA_DATA(kind));
+			if (rtattr_strlcpy(act_name, kind,
+			                   IFNAMSIZ) >= IFNAMSIZ)
 				goto err_out;
-			}
 		} else {
 			printk("Action bad kind\n");
 			goto err_out;
@@ -492,7 +489,7 @@
                             struct nlmsghdr *n, u32 pid)
 {
 	struct tc_action_ops *a_o;
-	char act_name[4 + IFNAMSIZ + 1];
+	char act_name[IFNAMSIZ];
 	struct rtattr *tb[TCA_ACT_MAX+1];
 	struct rtattr *kind;
 	int index;
@@ -502,12 +499,8 @@
 		goto err_out;
 	kind = tb[TCA_ACT_KIND-1];
 	if (kind != NULL) {
-		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-			printk("tcf_action_get_1: action %s bad\n",
-			       (char*)RTA_DATA(kind));
+		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
 			goto err_out;
-		}
 	} else {
 		printk("tcf_action_get_1: action bad kind\n");
 		goto err_out;
@@ -562,16 +555,12 @@
 
 static struct tc_action_ops *get_ao(struct rtattr *kind, struct tc_action *a)
 {
-	char act_name[4 + IFNAMSIZ + 1];
+	char act_name[IFNAMSIZ];
 	struct tc_action_ops *a_o;
 
 	if (kind != NULL) {
-		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-			printk("get_ao: action %s bad\n",
-			       (char*)RTA_DATA(kind));
+		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
 			return NULL;
-		}
 	} else {
 		printk("get_ao: action bad kind\n");
 		return NULL;
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2005-01-10 06:22:06 +01:00
+++ b/net/sched/cls_api.c	2005-01-10 06:22:06 +01:00
@@ -215,9 +215,10 @@
 #ifdef CONFIG_KMOD
 		if (tp_ops==NULL && tca[TCA_KIND-1] != NULL) {
 			struct rtattr *kind = tca[TCA_KIND-1];
+			char name[IFNAMSIZ];
 
-			if (RTA_PAYLOAD(kind) <= IFNAMSIZ) {
-				request_module("cls_%s", (char*)RTA_DATA(kind));
+			if (rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+				request_module("cls_%s", name);
 				tp_ops = tcf_proto_lookup_ops(kind);
 			}
 		}
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2005-01-10 06:22:06 +01:00
+++ b/net/sched/sch_api.c	2005-01-10 06:22:06 +01:00
@@ -407,8 +407,9 @@
 	ops = qdisc_lookup_ops(kind);
 #ifdef CONFIG_KMOD
 	if (ops==NULL && tca[TCA_KIND-1] != NULL) {
-		if (RTA_PAYLOAD(kind) <= IFNAMSIZ) {
-			request_module("sch_%s", (char*)RTA_DATA(kind));
+		char name[IFNAMSIZ];
+		if (rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+			request_module("sch_%s", name);
 			ops = qdisc_lookup_ops(kind);
 		}
 	}

--------------000600010406060406060801--
