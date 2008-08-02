From: "Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
Subject: [PATCH 3/3] drivers/net: coding styles fixes to drivers/net/8390.c
Date: Sat,  2 Aug 2008 15:55:13 -0300
Message-ID: <1217703313-23407-4-git-send-email-gustavo@las.ic.unicamp.br>
References: <gustavo@las.ic.unicamp.br>
 <1217703313-23407-1-git-send-email-gustavo@las.ic.unicamp.br>
 <1217703313-23407-2-git-send-email-gustavo@las.ic.unicamp.br>
 <1217703313-23407-3-git-send-email-gustavo@las.ic.unicamp.br>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: p_gortmaker@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from argonath.las.ic.unicamp.br ([143.106.60.116]:36311 "EHLO
	mail.las.ic.unicamp.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239AbYHBSzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 14:55:17 -0400
In-Reply-To: <1217703313-23407-3-git-send-email-gustavo@las.ic.unicamp.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix all errors and warnings reported by checkpatch.pl

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
---
 drivers/net/8390.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/8390.c b/drivers/net/8390.c
index dc5d258..f72a2e8 100644
--- a/drivers/net/8390.c
+++ b/drivers/net/8390.c
@@ -9,42 +9,39 @@ int ei_open(struct net_device *dev)
 {
 	return __ei_open(dev);
 }
+EXPORT_SYMBOL(ei_open);
 
 int ei_close(struct net_device *dev)
 {
 	return __ei_close(dev);
 }
+EXPORT_SYMBOL(ei_close);
 
 irqreturn_t ei_interrupt(int irq, void *dev_id)
 {
 	return __ei_interrupt(irq, dev_id);
 }
+EXPORT_SYMBOL(ei_interrupt);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void ei_poll(struct net_device *dev)
 {
 	__ei_poll(dev);
 }
+EXPORT_SYMBOL(ei_poll);
 #endif
 
 struct net_device *__alloc_ei_netdev(int size)
 {
 	return ____alloc_ei_netdev(size);
 }
+EXPORT_SYMBOL(__alloc_ei_netdev);
 
 void NS8390_init(struct net_device *dev, int startp)
 {
 	__NS8390_init(dev, startp);
 }
-
-EXPORT_SYMBOL(ei_open);
-EXPORT_SYMBOL(ei_close);
-EXPORT_SYMBOL(ei_interrupt);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-EXPORT_SYMBOL(ei_poll);
-#endif
 EXPORT_SYMBOL(NS8390_init);
-EXPORT_SYMBOL(__alloc_ei_netdev);
 
 #if defined(MODULE)
 
-- 
1.5.4.5

