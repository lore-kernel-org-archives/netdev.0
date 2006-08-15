From: akpm@osdl.org
Subject: [patch 11/41] es3210 section fix
Date: Mon, 14 Aug 2006 23:00:02 -0700
Message-ID: <200608150600.k7F602BG012633@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22674 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965131AbWHOGAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:12 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/es3210.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0xdf) and 'es_close'
WARNING: drivers/net/es3210.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x100) and 'es_close'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/es3210.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/es3210.c~es3210-section-fix drivers/net/es3210.c
--- a/drivers/net/es3210.c~es3210-section-fix
+++ a/drivers/net/es3210.c
@@ -421,8 +421,7 @@ MODULE_PARM_DESC(mem, "memory base addre
 MODULE_DESCRIPTION("Racal-Interlan ES3210 EISA ethernet driver");
 MODULE_LICENSE("GPL");
 
-int
-init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
_
