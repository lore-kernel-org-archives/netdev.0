From: domen@coderock.org
Subject: [patch 24/26] drivers/net/wan/lmc/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 11:33:57 +0100
Message-ID: <20050306103357.7A7A51F23C@trashy.coderock.org>
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


 kj-domen/drivers/net/wan/lmc/lmc_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wan/lmc/lmc_main.c~pci_register_driver-drivers_net_wan_lmc drivers/net/wan/lmc/lmc_main.c
--- kj/drivers/net/wan/lmc/lmc_main.c~pci_register_driver-drivers_net_wan_lmc	2005-03-05 16:12:42.000000000 +0100
+++ kj-domen/drivers/net/wan/lmc/lmc_main.c	2005-03-05 16:12:42.000000000 +0100
@@ -1794,7 +1794,7 @@ static struct pci_driver lmc_driver = {
 
 static int __init init_lmc(void)
 {
-    return pci_module_init(&lmc_driver);
+    return pci_register_driver(&lmc_driver);
 }
 
 static void __exit exit_lmc(void)
_
