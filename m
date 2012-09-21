From: pablo@netfilter.org
Subject: [PATCH] netlink: use <linux/export.h> instead of <linux/module.h>
Date: Fri, 21 Sep 2012 21:35:38 +0200
Message-ID: <1348256138-15500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45040 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861Ab2IUThA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 15:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Since (9f00d97 netlink: hide struct module parameter in netlink_kernel_create),
linux/netlink.h includes linux/module.h because of the use of THIS_MODULE.

Use linux/export.h instead, as suggested by Stephen Rothwell, which is
significantly smaller and defines THIS_MODULES.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netlink.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 73ade5f..b3dc992 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -153,7 +153,7 @@ struct nlattr {
 
 #include <linux/capability.h>
 #include <linux/skbuff.h>
-#include <linux/module.h>
+#include <linux/export.h>
 #include <net/scm.h>
 
 struct net;
-- 
1.7.10.4
