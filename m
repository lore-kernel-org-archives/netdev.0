From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 7/8] skbuff: Convert skb_push to return void *
Date: Mon,  4 May 2015 13:05:51 -0700
Message-ID: <5c15be6d71e0bcc1cace202dc0981d6dae119a7f.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0090.hostedemail.com ([216.40.44.90]:47594 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751617AbbEDUGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:23 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay07.hostedemail.com (Postfix) with ESMTP id A9555C1F83
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:22 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:22 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many casts that could be removed by this conversion.
Start it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/skbuff.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5941fde..1530487 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1689,7 +1689,7 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
-unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
+void *skb_push(struct sk_buff *skb, unsigned int len);
 void *skb_push_uchar(struct sk_buff *skb, unsigned char uc);
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 {
-- 
2.1.4
