From: maximilian attems <janitor@sternwelten.at>
Subject: [patch-kj] remove old ifdef'd code from eepro100.c
Date: Mon, 21 Jun 2004 20:51:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621185135.GA1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: saw@saw.sw.com.sg
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 From: Domen Puncer <domen@coderock.org>
 Patches to remove some old ifdefs.
 remove unused #include <linux/version.h>

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.7-max/drivers/net/eepro100.c |   17 -----------------
 1 files changed, 17 deletions(-)

diff -puN drivers/net/eepro100.c~remove-old-ifdefs-eepro100 drivers/net/eepro100.c
--- linux-2.6.7/drivers/net/eepro100.c~remove-old-ifdefs-eepro100	2004-06-18 09:15:04.000000000 +0200
+++ linux-2.6.7-max/drivers/net/eepro100.c	2004-06-18 09:15:04.000000000 +0200
@@ -94,7 +94,6 @@ static int options[] = {-1, -1, -1, -1, 
 #endif
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -2453,22 +2452,6 @@ static struct pci_driver eepro100_driver
 #endif /* CONFIG_PM */
 };
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,48)
-static int pci_module_init(struct pci_driver *pdev)
-{
-	int rc;
-
-	rc = pci_register_driver(pdev);
-	if (rc <= 0) {
-		printk(KERN_INFO "%s: No cards found, driver not installed.\n",
-			   pdev->name);
-		pci_unregister_driver(pdev);
-		return -ENODEV;
-	}
-	return 0;
-}
-#endif
-
 static int __init eepro100_init_module(void)
 {
 #ifdef MODULE

_
