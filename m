From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] ipv4: Kill RTO_CONN.
Date: Tue, 26 Apr 2011 15:12:07 -0700 (PDT)
Message-ID: <20110426.151207.232736415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758444Ab1DZWMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 18:12:40 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 28EAB24C088
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 15:12:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's not used by anything in the kernel, and defined in net/route.h so
never exported to userspace.

Therefore we can safely remove it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 79530da..fdbdb92 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -37,10 +37,6 @@
 
 #define RTO_ONLINK	0x01
 
-#define RTO_CONN	0
-/* RTO_CONN is not used (being alias for 0), but preserved not to break
- * some modules referring to it. */
-
 #define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
 
 struct fib_nh;
-- 
1.7.4.5

