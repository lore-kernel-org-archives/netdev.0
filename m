From: domen@coderock.org
Subject: [patch 21/26] drivers/net/skfp/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 11:33:46 +0100
Message-ID: <20050306103347.652131F23F@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, c.lucas@ifrance.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


convert from pci_module_init to pci_register_driver
(from:http://kerneljanitors.org/TODO).

Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/skfp/skfddi.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/skfp/skfddi.c~pci_register_driver-drivers_net_skfp drivers/net/skfp/skfddi.c
--- kj/drivers/net/skfp/skfddi.c~pci_register_driver-drivers_net_skfp	2005-03-05 16:12:37.000000000 +0100
+++ kj-domen/drivers/net/skfp/skfddi.c	2005-03-05 16:12:37.000000000 +0100
@@ -2281,7 +2281,7 @@ static struct pci_driver skfddi_pci_driv
 
 static int __init skfd_init(void)
 {
-	return pci_module_init(&skfddi_pci_driver);
+	return pci_register_driver(&skfddi_pci_driver);
 }
 
 static void __exit skfd_exit(void)
_
