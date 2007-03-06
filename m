From: akpm@linux-foundation.org
Subject: [patch 14/19] drivers/net/vioc/vioc_driver.c: replace pci_module_init with pci_register_driver
Date: Tue, 06 Mar 2007 02:41:58 -0800
Message-ID: <200703061041.l26AfwFn019774@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ricknu-0@student.ltu.se, driver-support@fabric7.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34739 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934074AbXCFKm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Knutsson <ricknu-0@student.ltu.se>

Replace pci_module_init with pci_register_driver

Signed-off-by: Richard Knutson <ricknu-0@student.ltu.se>
Cc: <support@fabric7.com>
Cc: <driver-support@fabric7.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/vioc/vioc_driver.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/vioc/vioc_driver.c~drivers-net-vioc-vioc_driverc-replace-pci_module_init-with-pci_register_driver drivers/net/vioc/vioc_driver.c
--- a/drivers/net/vioc/vioc_driver.c~drivers-net-vioc-vioc_driverc-replace-pci_module_init-with-pci_register_driver
+++ a/drivers/net/vioc/vioc_driver.c
@@ -841,9 +841,9 @@ static int __init vioc_module_init(void)
 	vioc_irq_init();
 	spp_init();
 
-	ret = pci_module_init(&vioc_driver);
+	ret = pci_register_driver(&vioc_driver);
 	if (ret) {
-		printk(KERN_ERR "%s: pci_module_init() -> %d\n", __FUNCTION__,
+		printk(KERN_ERR "%s: pci_register_driver() -> %d\n", __FUNCTION__,
 		       ret);
 		vioc_irq_exit();
 		return ret;
_
