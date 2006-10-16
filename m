From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 1/13] [IPV6] Remove struct pol_chain.
Date: Tue, 17 Oct 2006 02:54:27 +0300
Message-ID: <45341BB3.6090907@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:50449 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422950AbWJPXy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 19:54:29 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Struct pol_chain has existed since at least the 2.2 kernel, but isn't used
anymore. As the IPv6 policy routing is implemented in a totally different
way in the current kernel, just get rid of it.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 include/net/ip6_route.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 6ca6b71..c14b70e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -36,13 +36,6 @@ #define RT6_LOOKUP_F_IFACE	0x1
 #define RT6_LOOKUP_F_REACHABLE	0x2
 #define RT6_LOOKUP_F_HAS_SADDR	0x4

-struct pol_chain {
-	int			type;
-	int			priority;
-	struct fib6_node	*rules;
-	struct pol_chain	*next;
-};
-
 extern struct rt6_info	ip6_null_entry;

 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-- 
1.4.2.3

