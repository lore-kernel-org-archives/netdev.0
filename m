From: akpm@osdl.org
Subject: [patch 08/41] e2100 section fix
Date: Mon, 14 Aug 2006 23:00:00 -0700
Message-ID: <200608150600.k7F600Mx012595@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59282 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965147AbWHOGBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:43 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/e2100.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0xd9) and 'e21_reset_8390'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e2100.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/e2100.c~e2100-section-fix drivers/net/e2100.c
--- a/drivers/net/e2100.c~e2100-section-fix
+++ a/drivers/net/e2100.c
@@ -425,8 +425,8 @@ MODULE_LICENSE("GPL");
 
 /* This is set up so that only a single autoprobe takes place per call.
 ISA device autoprobes on a running machine are not recommended. */
-int
-init_module(void)
+
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
_
