From: domen@coderock.org
Subject: [patch 20/26] drivers/net/arcnet/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 11:33:43 +0100
Message-ID: <20050306103344.11A721F208@trashy.coderock.org>
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


 kj-domen/drivers/net/arcnet/com20020-pci.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/arcnet/com20020-pci.c~pci_register_driver-drivers_net_arcnet drivers/net/arcnet/com20020-pci.c
--- kj/drivers/net/arcnet/com20020-pci.c~pci_register_driver-drivers_net_arcnet	2005-03-05 16:12:35.000000000 +0100
+++ kj-domen/drivers/net/arcnet/com20020-pci.c	2005-03-05 16:12:35.000000000 +0100
@@ -177,7 +177,7 @@ static struct pci_driver com20020pci_dri
 static int __init com20020pci_init(void)
 {
 	BUGLVL(D_NORMAL) printk(VERSION);
-	return pci_module_init(&com20020pci_driver);
+	return pci_register_driver(&com20020pci_driver);
 }
 
 static void __exit com20020pci_cleanup(void)
_
