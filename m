From: domen@coderock.org
Subject: [patch 3/3] drivers/net/wireless/prism54/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 23:23:58 +0100
Message-ID: <20050306222358.752961EC90@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, c.lucas@ifrance.com
To: prism54-private@prism54.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


convert from pci_module_init to pci_register_driver
(from:http://kerneljanitors.org/TODO).

Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wireless/prism54/islpci_hotplug.c~pci_register_driver-drivers_net_wireless_prism54 drivers/net/wireless/prism54/islpci_hotplug.c
--- kj/drivers/net/wireless/prism54/islpci_hotplug.c~pci_register_driver-drivers_net_wireless_prism54	2005-03-05 16:12:44.000000000 +0100
+++ kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c	2005-03-05 16:12:44.000000000 +0100
@@ -315,7 +315,7 @@ prism54_module_init(void)
 
 	__bug_on_wrong_struct_sizes ();
 
-	return pci_module_init(&prism54_driver);
+	return pci_register_driver(&prism54_driver);
 }
 
 /* by the time prism54_module_exit() terminates, as a postcondition
_
