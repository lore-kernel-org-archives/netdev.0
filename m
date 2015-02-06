From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] net: fix a typo in skb_checksum_validate_zero_check
Date: Fri,  6 Feb 2015 18:54:19 +0100
Message-ID: <1423245259-10369-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:47512 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753735AbbBFSBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 13:01:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove trailing underscore.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/linux/skbuff.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 59ad1c95182d..970305e40558 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3072,7 +3072,7 @@ static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
 
 #define skb_checksum_validate_zero_check(skb, proto, check,		\
 					 compute_pseudo)		\
-	__skb_checksum_validate_(skb, proto, true, true, check, compute_pseudo)
+	__skb_checksum_validate(skb, proto, true, true, check, compute_pseudo)
 
 #define skb_checksum_simple_validate(skb)				\
 	__skb_checksum_validate(skb, 0, true, false, 0, null_compute_pseudo)
-- 
2.3.0
