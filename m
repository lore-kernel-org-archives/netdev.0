From: akpm@linux-foundation.org
Subject: [patch 11/17] drivers/net/appletalk/ltpc.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:29 -0800
Message-ID: <200803042319.m24NJT4F002716@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49208 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935028AbYCDXTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/appletalk/ltpc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/appletalk/ltpc.c~drivers-net-appletalk-ltpcc-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/appletalk/ltpc.c
--- a/drivers/net/appletalk/ltpc.c~drivers-net-appletalk-ltpcc-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/appletalk/ltpc.c
@@ -1252,7 +1252,7 @@ module_param(irq, int, 0);
 module_param(dma, int, 0);
 
 
-int __init init_module(void)
+static int __init ltpc_module_init(void)
 {
         if(io == 0)
 		printk(KERN_NOTICE
@@ -1263,6 +1263,7 @@ int __init init_module(void)
 		return PTR_ERR(dev_ltpc);
 	return 0;
 }
+module_init(ltpc_module_init);
 #endif
 
 static void __exit ltpc_cleanup(void)
_
