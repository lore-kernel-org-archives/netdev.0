From: akpm@osdl.org
Subject: [patch 18/41] wd section fix
Date: Mon, 14 Aug 2006 23:00:06 -0700
Message-ID: <200608150600.k7F6079V012654@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62354 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965151AbWHOGBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:49 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/wd.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0xfd) and 'wd_open'
WARNING: drivers/net/wd.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x14b) and 'wd_open'
WARNING: drivers/net/wd.o - Section mismatch: reference to .init.data:wd_portlist from .text between 'init_module' (at offset 0x17f) and 'wd_open'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wd.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/wd.c~wd-section-fix drivers/net/wd.c
--- a/drivers/net/wd.c~wd-section-fix
+++ a/drivers/net/wd.c
@@ -500,8 +500,8 @@ MODULE_LICENSE("GPL");
 
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
