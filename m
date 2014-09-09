From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] ipv6: mcast: remove dead debugging defines
Date: Tue,  9 Sep 2014 13:07:32 +0200
Message-ID: <1410260852-25000-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466AbaIILHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 07:07:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not used anywhere, so just remove these.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/mcast.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 6833dd0..484a942 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -64,15 +64,6 @@
 
 #include <net/ip6_checksum.h>
 
-/* Set to 3 to get tracing... */
-#define MCAST_DEBUG 2
-
-#if MCAST_DEBUG >= 3
-#define MDBG(x) printk x
-#else
-#define MDBG(x)
-#endif
-
 /* Ensure that we have struct in6_addr aligned on 32bit word. */
 static void *__mld2_query_bugs[] __attribute__((__unused__)) = {
 	BUILD_BUG_ON_NULL(offsetof(struct mld2_query, mld2q_srcs) % 4),
-- 
1.7.11.7
