From: akpm@osdl.org
Subject: [patch 3/9] drivers/atm: No need to return void
Date: Fri, 20 Oct 2006 14:43:03 -0700
Message-ID: <200610202143.k9KLh3b1003768@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, tklauser@distanz.ch,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60804 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992763AbWJTVoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:44:01 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobias Klauser <tklauser@distanz.ch>

The module_exit function has return-type void and pci_unregister_driver()
returns void anyway.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/atm/ambassador.c |    4 ++--
 drivers/atm/horizon.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/atm/ambassador.c~drivers-atm-no-need-to-return-void drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c~drivers-atm-no-need-to-return-void
+++ a/drivers/atm/ambassador.c
@@ -2452,8 +2452,8 @@ static int __init amb_module_init (void)
 static void __exit amb_module_exit (void)
 {
   PRINTD (DBG_FLOW|DBG_INIT, "cleanup_module");
-  
-  return pci_unregister_driver(&amb_driver);
+
+  pci_unregister_driver(&amb_driver);
 }
 
 module_init(amb_module_init);
diff -puN drivers/atm/horizon.c~drivers-atm-no-need-to-return-void drivers/atm/horizon.c
--- a/drivers/atm/horizon.c~drivers-atm-no-need-to-return-void
+++ a/drivers/atm/horizon.c
@@ -2932,8 +2932,8 @@ static int __init hrz_module_init (void)
 
 static void __exit hrz_module_exit (void) {
   PRINTD (DBG_FLOW, "cleanup_module");
-  
-  return pci_unregister_driver(&hrz_driver);
+
+  pci_unregister_driver(&hrz_driver);
 }
 
 module_init(hrz_module_init);
_
