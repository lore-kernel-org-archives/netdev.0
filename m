From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] remove third bogus argument from NLA_PUT_FLAG
Date: Fri, 25 Aug 2006 12:55:26 +0200
Message-ID: <1156503326.4090.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60355 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751436AbWHYKy5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 06:54:57 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the 'value' argument from NLA_PUT_FLAG which is
unused anyway. The documentation comment was already correct so it
doesn't need an update :)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/netlink.h	2006-08-25 12:46:30.000000000 +0200
+++ wireless-dev/include/net/netlink.h	2006-08-25 12:46:38.000000000 +0200
@@ -758,7 +758,7 @@ static inline int nla_put_msecs(struct s
 #define NLA_PUT_STRING(skb, attrtype, value) \
 	NLA_PUT(skb, attrtype, strlen(value) + 1, value)
 
-#define NLA_PUT_FLAG(skb, attrtype, value) \
+#define NLA_PUT_FLAG(skb, attrtype) \
 	NLA_PUT(skb, attrtype, 0, NULL)
 
 #define NLA_PUT_MSECS(skb, attrtype, jiffies) \

