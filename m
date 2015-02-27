From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next] ipv6: convert printk call to pr_err macro
Date: Fri, 27 Feb 2015 01:14:10 +0000
Message-ID: <1424999650-25847-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:54399 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752483AbbB0BOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 20:14:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change a printk(KERN_ERR to a pr_err macro. No changes detected by
objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/exthdrs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 8af3eb5..2f2945d 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -198,7 +198,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 
 		ip6 = skb_header_pointer(skb, *offset, sizeof(_ip6), &_ip6);
 		if (!ip6 || (ip6->version != 6)) {
-			printk(KERN_ERR "IPv6 header not found\n");
+			pr_err("IPv6 header not found\n");
 			return -EBADMSG;
 		}
 		start = *offset + sizeof(struct ipv6hdr);
-- 
1.9.1
