From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 3/4] ipv6: coding style - convert printk
Date: Tue,  2 Sep 2014 20:16:03 +0100
Message-ID: <1409685364-4327-4-git-send-email-ipm@chirality.org.uk>
References: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36330 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754581AbaIBTQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 15:16:14 -0400
In-Reply-To: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No change in the object output is detected by the objdiff script.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/exthdrs_core.c |    2 +-
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
1.7.9.5
