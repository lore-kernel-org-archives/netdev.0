From: "Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
Subject: [PATCH 2/3] drivers/net: coding styles fixes to drivers/net/8390p.c
Date: Sat,  2 Aug 2008 15:55:12 -0300
Message-ID: <1217703313-23407-3-git-send-email-gustavo@las.ic.unicamp.br>
References: <gustavo@las.ic.unicamp.br>
 <1217703313-23407-1-git-send-email-gustavo@las.ic.unicamp.br>
 <1217703313-23407-2-git-send-email-gustavo@las.ic.unicamp.br>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: p_gortmaker@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from argonath.las.ic.unicamp.br ([143.106.60.116]:36310 "EHLO
	mail.las.ic.unicamp.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbYHBSzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 14:55:17 -0400
In-Reply-To: <1217703313-23407-2-git-send-email-gustavo@las.ic.unicamp.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix all errors and warnings reported by checkpatch.pl

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
---
 drivers/net/8390p.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/8390p.c b/drivers/net/8390p.c
index fd46f6c..4c6eea4 100644
--- a/drivers/net/8390p.c
+++ b/drivers/net/8390p.c
@@ -4,9 +4,9 @@ static const char version[] =
     "8390p.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
 
 #define ei_inb(_p)	inb(_p)
-#define ei_outb(_v,_p)	outb(_v,_p)
+#define ei_outb(_v, _p)	outb(_v, _p)
 #define ei_inb_p(_p)	inb_p(_p)
-#define ei_outb_p(_v,_p) outb_p(_v,_p)
+#define ei_outb_p(_v, _p) outb_p(_v, _p)
 
 #include "lib8390.c"
 
@@ -14,42 +14,39 @@ int eip_open(struct net_device *dev)
 {
 	return __ei_open(dev);
 }
+EXPORT_SYMBOL(eip_open);
 
 int eip_close(struct net_device *dev)
 {
 	return __ei_close(dev);
 }
+EXPORT_SYMBOL(eip_close);
 
 irqreturn_t eip_interrupt(int irq, void *dev_id)
 {
 	return __ei_interrupt(irq, dev_id);
 }
+EXPORT_SYMBOL(eip_interrupt);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void eip_poll(struct net_device *dev)
 {
 	__ei_poll(dev);
 }
+EXPORT_SYMBOL(eip_poll);
 #endif
 
 struct net_device *__alloc_eip_netdev(int size)
 {
 	return ____alloc_ei_netdev(size);
 }
+EXPORT_SYMBOL(__alloc_eip_netdev);
 
 void NS8390p_init(struct net_device *dev, int startp)
 {
 	__NS8390_init(dev, startp);
 }
-
-EXPORT_SYMBOL(eip_open);
-EXPORT_SYMBOL(eip_close);
-EXPORT_SYMBOL(eip_interrupt);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-EXPORT_SYMBOL(eip_poll);
-#endif
 EXPORT_SYMBOL(NS8390p_init);
-EXPORT_SYMBOL(__alloc_eip_netdev);
 
 #if defined(MODULE)
 
-- 
1.5.4.5

