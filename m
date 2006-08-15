From: akpm@osdl.org
Subject: [patch 14/41] lne390 section fix
Date: Mon, 14 Aug 2006 23:00:04 -0700
Message-ID: <200608150600.k7F6042a012642@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24978 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965128AbWHOGAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:15 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/lne390.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x100) and 'lne390_close'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/lne390.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/lne390.c~lne390-section-fix drivers/net/lne390.c
--- a/drivers/net/lne390.c~lne390-section-fix
+++ a/drivers/net/lne390.c
@@ -406,7 +406,7 @@ MODULE_PARM_DESC(mem, "memory base addre
 MODULE_DESCRIPTION("Mylex LNE390A/B EISA Ethernet driver");
 MODULE_LICENSE("GPL");
 
-int init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
_
