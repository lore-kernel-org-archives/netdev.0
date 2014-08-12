From: akpm@linux-foundation.org
Subject: [patch 1/1] drivers/net/irda/donauboe.c: convert to
 module_pci_driver
Date: Tue, 12 Aug 2014 13:31:54 -0700
Message-ID: <53ea79ba.8fEEEBaYTgGJgBaz%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: samuel@sortiz.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, clbchenlibo.chen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:44532 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbaHLUiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 16:38:51 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so1938539oah.0
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 13:38:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: drivers/net/irda/donauboe.c: convert to module_pci_driver

Signed-off-by: Libo Chen <libo.chen@huawei.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/donauboe.c |   15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff -puN drivers/net/irda/donauboe.c~drivers-net-irda-donauboe-convert-to-module_pci_driver drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c~drivers-net-irda-donauboe-convert-to-module_pci_driver
+++ a/drivers/net/irda/donauboe.c
@@ -1755,17 +1755,4 @@ static struct pci_driver donauboe_pci_dr
 	.resume		= toshoboe_wakeup 
 };
 
-static int __init
-donauboe_init (void)
-{
-  return pci_register_driver(&donauboe_pci_driver);
-}
-
-static void __exit
-donauboe_cleanup (void)
-{
-  pci_unregister_driver(&donauboe_pci_driver);
-}
-
-module_init(donauboe_init);
-module_exit(donauboe_cleanup);
+module_pci_driver(donauboe_pci_driver);
_
