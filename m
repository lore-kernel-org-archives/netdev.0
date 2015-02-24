From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next] ipv6: remove dead debug code from ip6_tunnel.c
Date: Tue, 24 Feb 2015 12:01:25 +0000
Message-ID: <1424779285-27177-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:51840 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752489AbbBXMGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 07:06:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IP6_TNL_TRACE macro is no longer used anywhere in the code so remove definition.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/ip6_tunnel.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 266a264..88300d4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -64,12 +64,6 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("ip6tnl");
 MODULE_ALIAS_NETDEV("ip6tnl0");
 
-#ifdef IP6_TNL_DEBUG
-#define IP6_TNL_TRACE(x...) pr_debug("%s:" x "\n", __func__)
-#else
-#define IP6_TNL_TRACE(x...) do {;} while(0)
-#endif
-
 #define HASH_SIZE_SHIFT  5
 #define HASH_SIZE (1 << HASH_SIZE_SHIFT)
 
-- 
1.9.1
