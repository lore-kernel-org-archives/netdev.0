From: janitor@sternwelten.at
Subject: [patch 4/4]  8139cp net driver: add MODULE_VERSION
Date: Sat, 20 Nov 2004 03:45:10 +0100
Message-ID: <E1CVLFO-0002Im-G4@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, felipewd@terra.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




	Hi Jeff,

	Add MODULE_VERSION to 8139cp net driver.

	Cheers,

Felipe


Signed-off-by: Felipe W Damasio <felipewd@terra.com.br>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc2-bk4-max/drivers/net/8139cp.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/8139cp.c~add_module_version-drivers_net_8139cp drivers/net/8139cp.c
--- linux-2.6.10-rc2-bk4/drivers/net/8139cp.c~add_module_version-drivers_net_8139cp	2004-11-19 17:18:43.000000000 +0100
+++ linux-2.6.10-rc2-bk4-max/drivers/net/8139cp.c	2004-11-19 17:18:43.000000000 +0100
@@ -91,6 +91,7 @@ KERN_INFO DRV_NAME ": 10/100 PCI Etherne
 
 MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
 MODULE_DESCRIPTION("RealTek RTL-8139C+ series 10/100 PCI Ethernet driver");
+MODULE_VERSION(DRV_VERSION);
 MODULE_LICENSE("GPL");
 
 static int debug = -1;
_
