From: akpm@osdl.org
Subject: [patch 04/41] ac3200 section fixes
Date: Mon, 14 Aug 2006 22:59:57 -0700
Message-ID: <200608150559.k7F5xwTF012583@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15762 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965125AbWHOGAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:03 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/ac3200.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0xf9) and 'ac_close_card'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ac3200.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ac3200.c~ac3200-section-fixes drivers/net/ac3200.c
--- a/drivers/net/ac3200.c~ac3200-section-fixes
+++ a/drivers/net/ac3200.c
@@ -370,8 +370,7 @@ MODULE_PARM_DESC(mem, "Memory base addre
 MODULE_DESCRIPTION("Ansel AC3200 EISA ethernet driver");
 MODULE_LICENSE("GPL");
 
-int
-init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
_
