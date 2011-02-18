From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7] ipv4: Mark fib_combine_itag()'s 'res' arg as const.
Date: Thu, 17 Feb 2011 16:12:09 -0800 (PST)
Message-ID: <20110217.161209.98876001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756087Ab1BRALd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:33 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8E7AC24C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:12:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 08b46b8..b3019d8 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -232,7 +232,7 @@ extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res
 extern void fib_trie_init(void);
 extern struct fib_table *fib_trie_table(u32 id);
 
-static inline void fib_combine_itag(u32 *itag, struct fib_result *res)
+static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 {
 #ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-- 
1.7.4.1

