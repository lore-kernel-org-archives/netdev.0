From: akpm@osdl.org
Subject: [patch 12/41] eth16i section fix
Date: Mon, 14 Aug 2006 23:00:03 -0700
Message-ID: <200608150600.k7F603U1012636@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21138 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965129AbWHOGAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:11 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/eth16i.o - Section mismatch: reference to .init.data:cardname from .text between 'init_module' (at offset 0x6d2) and 'eth16i_multicast'
WARNING: drivers/net/eth16i.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x6ef) and 'eth16i_multicast'
WARNING: drivers/net/eth16i.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x702) and 'eth16i_multicast'
WARNING: drivers/net/eth16i.o - Section mismatch: reference to .init.data:cardname from .text between 'init_module' (at offset 0x70e) and 'eth16i_multicast'
WARNING: drivers/net/eth16i.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x71d) and 'eth16i_multicast'
WARNING: drivers/net/eth16i.o - Section mismatch: reference to .init.data:cardname from .text between 'init_module' (at offset 0x729) and 'eth16i_multicast'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/eth16i.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/eth16i.c~eth16i-section-fix drivers/net/eth16i.c
--- a/drivers/net/eth16i.c~eth16i-section-fix
+++ a/drivers/net/eth16i.c
@@ -1434,7 +1434,7 @@ MODULE_PARM_DESC(mediatype, "eth16i medi
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "eth16i debug level (0-6)");
 
-int init_module(void)
+int __init init_module(void)
 {
 	int this_dev, found = 0;
 	struct net_device *dev;
_
