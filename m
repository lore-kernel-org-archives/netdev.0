From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] genetlink: cleanup code according to CodingStyle
Date: Mon, 26 Jul 2010 14:46:01 +0800
Message-ID: <1280126761-29549-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:60836 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab0GZGqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 02:46:14 -0400
Received: by pxi14 with SMTP id 14so4429680pxi.19
        for <netdev@vger.kernel.org>; Sun, 25 Jul 2010 23:46:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the function is exported, the EXPORT* macro for it should follow immediately
after the closing function brace line.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/netlink/genetlink.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index aa4308a..e09e17a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -303,6 +303,7 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 errout:
 	return err;
 }
+EXPORT_SYMBOL(genl_register_ops);
 
 /**
  * genl_unregister_ops - unregister generic netlink operations
@@ -337,6 +338,7 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 
 	return -ENOENT;
 }
+EXPORT_SYMBOL(genl_unregister_ops);
 
 /**
  * genl_register_family - register a generic netlink family
@@ -405,6 +407,7 @@ errout_locked:
 errout:
 	return err;
 }
+EXPORT_SYMBOL(genl_register_family);
 
 /**
  * genl_register_family_with_ops - register a generic netlink family
@@ -485,6 +488,7 @@ int genl_unregister_family(struct genl_family *family)
 
 	return -ENOENT;
 }
+EXPORT_SYMBOL(genl_unregister_family);
 
 static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
@@ -899,11 +903,6 @@ problem:
 
 subsys_initcall(genl_init);
 
-EXPORT_SYMBOL(genl_register_ops);
-EXPORT_SYMBOL(genl_unregister_ops);
-EXPORT_SYMBOL(genl_register_family);
-EXPORT_SYMBOL(genl_unregister_family);
-
 static int genlmsg_mcast(struct sk_buff *skb, u32 pid, unsigned long group,
 			 gfp_t flags)
 {
