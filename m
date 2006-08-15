From: akpm@osdl.org
Subject: [patch 20/41] seeq8005 section fix
Date: Mon, 14 Aug 2006 23:00:08 -0700
Message-ID: <200608150600.k7F608SQ012660@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58514 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965149AbWHOGBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:43 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/seeq8005.o - Section mismatch: reference to .init.text:seeq8005_probe from .text between 'init_module' (at offset 0x106) and 'seeq8005_open'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/seeq8005.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/seeq8005.c~seeq8005-section-fix drivers/net/seeq8005.c
--- a/drivers/net/seeq8005.c~seeq8005-section-fix
+++ a/drivers/net/seeq8005.c
@@ -742,7 +742,7 @@ module_param(irq, int, 0);
 MODULE_PARM_DESC(io, "SEEQ 8005 I/O base address");
 MODULE_PARM_DESC(irq, "SEEQ 8005 IRQ number");
 
-int init_module(void)
+int __init init_module(void)
 {
 	dev_seeq = seeq8005_probe(-1);
 	if (IS_ERR(dev_seeq))
_
