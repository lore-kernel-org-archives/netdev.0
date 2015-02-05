From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 11/29] net: Flip nl_info to net_ctx
Date: Wed,  4 Feb 2015 18:34:12 -0700
Message-ID: <1423100070-31848-12-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:60506 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324AbbBEBgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:02 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so35415603iga.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:01 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/netlink.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index e010ee8da41d..587a6ef973e5 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 #include <linux/netlink.h>
 #include <linux/jiffies.h>
+#include <net/net_namespace.h>
 
 /* ========================================================================
  *         Netlink Messages and Attributes Interface (As Seen On TV)
@@ -221,7 +222,8 @@ struct nla_policy {
  */
 struct nl_info {
 	struct nlmsghdr		*nlh;
-	struct net		*nl_net;
+	struct net_ctx		nl_net_ctx;
+#define nl_net  nl_net_ctx.net
 	u32			portid;
 };
 
-- 
1.9.3 (Apple Git-50)
