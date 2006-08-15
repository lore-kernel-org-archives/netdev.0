From: akpm@osdl.org
Subject: [patch 06/41] cs89x0 section fix
Date: Mon, 14 Aug 2006 22:59:59 -0700
Message-ID: <200608150559.k7F5xxmf012589@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18834 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965128AbWHOGAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:06 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/cs89x0.o - Section mismatch: reference to .init.data:version from .text between 'init_module' (at offset 0x13d8) and 'net_get_stats'
WARNING: drivers/net/cs89x0.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x1634) and 'net_get_stats'
WARNING: drivers/net/cs89x0.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x1a1f) and 'net_get_stats'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/cs89x0.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/cs89x0.c~cs89x0-section-fix drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c~cs89x0-section-fix
+++ a/drivers/net/cs89x0.c
@@ -1905,8 +1905,7 @@ MODULE_LICENSE("GPL");
 
 */
 
-int
-init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
 	struct net_local *lp;
_
