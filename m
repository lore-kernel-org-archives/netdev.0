From: akpm@linux-foundation.org
Subject: [patch 15/28] drivers/net/wan/hdlc_fr.c: kmalloc + memset conversion to kzalloc
Date: Fri, 10 Aug 2007 14:11:58 -0700
Message-ID: <200708102111.l7ALBxJj009417@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	m.kozlowski@tuxland.pl, khc@pm.waw.pl
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40952 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942242AbXHJVMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/wan/hdlc_fr.c | 31260 -> 31223 (-37 bytes)
 drivers/net/wan/hdlc_fr.o | 144872 -> 144728 (-144 bytes)

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/hdlc_fr.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/wan/hdlc_fr.c~drivers-net-wan-hdlc_frc-kmalloc-memset-conversion-to-kzalloc drivers/net/wan/hdlc_fr.c
--- a/drivers/net/wan/hdlc_fr.c~drivers-net-wan-hdlc_frc-kmalloc-memset-conversion-to-kzalloc
+++ a/drivers/net/wan/hdlc_fr.c
@@ -212,14 +212,13 @@ static pvc_device* add_pvc(struct net_de
 		pvc_p = &(*pvc_p)->next;
 	}
 
-	pvc = kmalloc(sizeof(pvc_device), GFP_ATOMIC);
+	pvc = kzalloc(sizeof(pvc_device), GFP_ATOMIC);
 #ifdef DEBUG_PVC
 	printk(KERN_DEBUG "add_pvc: allocated pvc %p, frad %p\n", pvc, dev);
 #endif
 	if (!pvc)
 		return NULL;
 
-	memset(pvc, 0, sizeof(pvc_device));
 	pvc->dlci = dlci;
 	pvc->frad = dev;
 	pvc->next = *pvc_p;	/* Put it in the chain */
_
