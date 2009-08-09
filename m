From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] net: include/linux/icmpv6: includecheck fix for icmpv6.h
Date: Sun, 09 Aug 2009 18:57:18 +0530
Message-ID: <1249824438.2957.10.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:47628 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbZHIN15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 09:27:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fix the following 'make includecheck' warning:

  include/linux/icmpv6.h: linux/skbuff.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 include/linux/icmpv6.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index b6a8518..c0d8357 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -171,8 +171,6 @@ struct icmp6_filter {
 #ifdef __KERNEL__
 
 #include <linux/netdevice.h>
-#include <linux/skbuff.h>
-
 
 extern void				icmpv6_send(struct sk_buff *skb,
 						    u8 type, u8 code,
-- 
1.6.0.6



