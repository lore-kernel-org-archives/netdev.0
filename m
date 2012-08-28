From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] skbuff: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 21:10:09 +0800
Message-ID: <CAPgLHd9m2VbFFXt5Q3MMrK6BPXvMrT-ptq+RfgBToXOpxAKOOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:47738 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab2H1NKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:10:11 -0400
Received: by qaas11 with SMTP id s11so2615491qaa.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 06:10:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 include/linux/skbuff.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7632c87..0b846d9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2464,8 +2464,7 @@ static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
 }
 static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
 {
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 }
 #endif
 #ifdef CONFIG_BRIDGE_NETFILTER
