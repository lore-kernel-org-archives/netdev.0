From: akpm@osdl.org
Subject: [patch 09/41] eepro section fix
Date: Mon, 14 Aug 2006 23:00:01 -0700
Message-ID: <200608150600.k7F601Bv012627@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21394 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965127AbWHOGAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:11 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/eepro.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x284) and 'eepro_ethtool_get_drvinfo'
WARNING: drivers/net/eepro.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x2a7) and 'eepro_ethtool_get_drvinfo'
WARNING: drivers/net/eepro.o - Section mismatch: reference to .init.data:eepro_portlist from .text between 'init_module' (at offset 0x2b3) and 'eepro_ethtool_get_drvinfo'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/eepro.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/eepro.c~eepro-section-fix drivers/net/eepro.c
--- a/drivers/net/eepro.c~eepro-section-fix
+++ a/drivers/net/eepro.c
@@ -1807,8 +1807,7 @@ MODULE_PARM_DESC(irq, "EtherExpress Pro/
 MODULE_PARM_DESC(mem, "EtherExpress Pro/10 Rx buffer size(es) in kB (3-29)");
 MODULE_PARM_DESC(autodetect, "EtherExpress Pro/10 force board(s) detection (0-1)");
 
-int
-init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int i;
_
