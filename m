From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mm] netxen: uses PCI
Date: Thu, 16 Nov 2006 21:39:11 -0800
Message-ID: <20061116213911.0fabf501.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: amitkale@netxen.com, jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50047 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1424774AbWKQFmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 00:42:02 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

drivers/built-in.o: In function `netxen_nic_remove':
netxen_nic_main.c:(.text+0x31b4d): undefined reference to `pci_disable_msi'
netxen_nic_main.c:(.text+0x31b8e): undefined reference to `pci_release_regions'
drivers/built-in.o: In function `netxen_init_module':
netxen_nic_main.c:(.init.text+0x3f17): undefined reference to `pci_module_init'
make: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-2619-rc5mm2.orig/drivers/net/Kconfig
+++ linux-2619-rc5mm2/drivers/net/Kconfig
@@ -2457,6 +2457,7 @@ config MYRI10GE
 
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
+	depends on PCI
 	help
 	  This enables the support for NetXen's Gigabit Ethernet card.
 


---
