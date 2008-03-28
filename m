From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [patch] net: Comment dev_kfree_skb_irq and dev_kfree_skb_any better
Date: Fri, 28 Mar 2008 08:13:36 -0700 (PDT)
Message-ID: <185527.39512.qm@web52004.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52004.mail.re2.yahoo.com ([206.190.49.251]:47662 "HELO
	web52004.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753170AbYC1PUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 11:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Comment dev_kfree_skb_irq and dev_kfree_skb_any better.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---

--- linux-2.6/include/linux/netdevice.h    2008-03-23 09:06:05.264803500 +0200
+++ linux/include/linux/netdevice.h    2008-03-28 17:08:33.568098500 +0200
@@ -1072,12 +1072,14 @@ static inline int netif_is_multiqueue(co
 }
 
 /* Use this variant when it is known for sure that it
- * is executing from interrupt context.
+ * is executing from hardware interrupt context or with hardware interrupts
+ * disabled.
  */
 extern void dev_kfree_skb_irq(struct sk_buff *skb);
 
 /* Use this variant in places where it could be invoked
- * either from interrupt or non-interrupt context.
+ * from either hardware interrupt or other context, with hardware interrupts
+ * either disabled or enabled.
  */
 extern void dev_kfree_skb_any(struct sk_buff *skb);
 





      ____________________________________________________________________________________
Be a better friend, newshound, and 
know-it-all with Yahoo! Mobile.  Try it now.  http://mobile.yahoo.com/;_ylt=Ahu06i62sR8HDtDypao8Wcj9tAcJ
