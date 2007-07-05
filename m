From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] skbuff: remove export of static symbol
Date: Thu, 05 Jul 2007 11:33:01 +0200
Message-ID: <1183627981.3818.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43203 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759041AbXGEJcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 05:32:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_clone_fraglist is static so it shouldn't be exported.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 net/core/skbuff.c |    1 -
 1 file changed, 1 deletion(-)

--- wireless-dev.orig/net/core/skbuff.c	2007-07-05 11:30:15.265640003 +0200
+++ wireless-dev/net/core/skbuff.c	2007-07-05 11:30:45.095640003 +0200
@@ -2211,7 +2211,6 @@ EXPORT_SYMBOL(pskb_copy);
 EXPORT_SYMBOL(pskb_expand_head);
 EXPORT_SYMBOL(skb_checksum);
 EXPORT_SYMBOL(skb_clone);
-EXPORT_SYMBOL(skb_clone_fraglist);
 EXPORT_SYMBOL(skb_copy);
 EXPORT_SYMBOL(skb_copy_and_csum_bits);
 EXPORT_SYMBOL(skb_copy_and_csum_dev);


