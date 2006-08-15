From: akpm@osdl.org
Subject: [patch 05/41] cops section fix
Date: Mon, 14 Aug 2006 22:59:58 -0700
Message-ID: <200608150559.k7F5xwDR012586@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63634 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965152AbWHOGBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:50 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/appletalk/cops.o - Section mismatch: reference to .init.text:cops_probe from .text between 'init_module' (at offset 0xae) and 'cops_rx'

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/appletalk/cops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/appletalk/cops.c~cops-section-fix drivers/net/appletalk/cops.c
--- a/drivers/net/appletalk/cops.c~cops-section-fix
+++ a/drivers/net/appletalk/cops.c
@@ -1030,7 +1030,7 @@ module_param(io, int, 0);
 module_param(irq, int, 0);
 module_param(board_type, int, 0);
 
-int init_module(void)
+int __init init_module(void)
 {
 	if (io == 0)
 		printk(KERN_WARNING "%s: You shouldn't autoprobe with insmod\n",
_
