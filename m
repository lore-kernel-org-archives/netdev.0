From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 4/13] [IPV6] Clean up BACKTRACK().
Date: Tue, 17 Oct 2006 03:06:27 +0300
Message-ID: <45341E83.7010409@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:60433 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422963AbWJQAG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:06:29 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The fn check is unnecessary as fn can never be NULL in BACKTRACK().

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1b0f07..263c057 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -484,7 +484,7 @@ #define BACKTRACK(saddr) \
 do { \
 	if (rt == &ip6_null_entry) { \
 		struct fib6_node *pn; \
-		while (fn) { \
+		while (1) { \
 			if (fn->fn_flags & RTN_TL_ROOT) \
 				goto out; \
 			pn = fn->parent; \
-- 
1.4.2.3
