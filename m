From: akpm@osdl.org
Subject: [patch 8/8] net: smc91x add missing bracket
Date: Mon, 04 Dec 2006 15:04:56 -0800
Message-ID: <200612042306.kB4N65mh008020@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, m.kozlowski@tuxland.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:53701 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937449AbWLDXGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:06:21 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/smc91x.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/smc91x.h~net-smc91x-add-missing-bracket drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~net-smc91x-add-missing-bracket
+++ a/drivers/net/smc91x.h
@@ -238,7 +238,7 @@ SMC_outw(u16 val, void __iomem *ioaddr, 
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
 
-#define SMC_inb(a, r)		inb((u32)a) + (r))
+#define SMC_inb(a, r)		inb(((u32)a) + (r))
 #define SMC_inw(a, r)		inw(((u32)a) + (r))
 #define SMC_outb(v, a, r)	outb(v, ((u32)a) + (r))
 #define SMC_outw(v, a, r)	outw(v, ((u32)a) + (r))
_
