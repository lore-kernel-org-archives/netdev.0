From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 5/8] skbuff: Convert skb_put to return void *
Date: Mon,  4 May 2015 13:05:49 -0700
Message-ID: <d2abbbdcc2a96b43ee3b2523d54551928102e5f7.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0067.hostedemail.com ([216.40.44.67]:42990 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752552AbbEDUGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:14 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay03.hostedemail.com (Postfix) with ESMTP id 7C4A76A8AC
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:13 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:12 +0000 (UTC)
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
index 30cd234..5941fde 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1678,7 +1678,7 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
  *	Add data to an sk_buff
  */
 unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
-unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
+void *skb_put(struct sk_buff *skb, unsigned int len);
 void *skb_put_uchar(struct sk_buff *skb, unsigned char uc);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 {
-- 
2.1.4
