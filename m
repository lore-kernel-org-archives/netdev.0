From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 22/22]: Don't export ing_filter
Date: Mon, 10 Jan 2005 20:38:20 +0100
Message-ID: <41E2D9AC.6020200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070207040900080702020703"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070207040900080702020703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------070207040900080702020703
Content-Type: text/x-patch;
 name="22.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="22.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 06:10:27+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Don't export ing_filter
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/core/dev.c
#   2005/01/10 06:10:20+01:00 kaber@coreworks.de +0 -5
#   [PKT_SCHED]: Don't export ing_filter
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/pkt_cls.h
#   2005/01/10 06:10:20+01:00 kaber@coreworks.de +0 -1
#   [PKT_SCHED]: Don't export ing_filter
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/pkt_cls.h b/include/net/pkt_cls.h
--- a/include/net/pkt_cls.h	2005-01-10 06:23:22 +01:00
+++ b/include/net/pkt_cls.h	2005-01-10 06:23:22 +01:00
@@ -17,7 +17,6 @@
 
 extern int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
-extern int ing_filter(struct sk_buff *skb);
 
 static inline unsigned long
 __cls_set_class(unsigned long *clp, unsigned long cl)
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2005-01-10 06:23:22 +01:00
+++ b/net/core/dev.c	2005-01-10 06:23:22 +01:00
@@ -3346,9 +3346,4 @@
 EXPORT_SYMBOL(dev_load);
 #endif
 
-#ifdef CONFIG_NET_CLS_ACT
-EXPORT_SYMBOL(ing_filter);
-#endif
-
-
 EXPORT_PER_CPU_SYMBOL(softnet_data);

--------------070207040900080702020703--
