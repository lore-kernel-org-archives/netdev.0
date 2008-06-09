From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make hplance_{init,cleanup}_module() static
Date: Tue, 10 Jun 2008 01:23:32 +0300
Message-ID: <20080609222332.GP1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:53978 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760064AbYFIWY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:24:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needlessly global hplance_{init,cleanup}_module() 
static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
7a4763982e5772a5a8c950ae494d88017cad0a83 diff --git a/drivers/net/hplance.c b/drivers/net/hplance.c
index be6e5bc..2e80263 100644
--- a/drivers/net/hplance.c
+++ b/drivers/net/hplance.c
@@ -220,12 +220,12 @@ static int hplance_close(struct net_device *dev)
         return 0;
 }
 
-int __init hplance_init_module(void)
+static int __init hplance_init_module(void)
 {
 	return dio_register_driver(&hplance_driver);
 }
 
-void __exit hplance_cleanup_module(void)
+static void __exit hplance_cleanup_module(void)
 {
         dio_unregister_driver(&hplance_driver);
 }

