From: Scott Feldman <sfeldma@pobox.com>
Subject: [PATCH 2.6] eepro100: remove ID for 82556
Date: Tue, 01 Feb 2005 11:11:46 -0800
Message-ID: <1107285106.3366.106.camel@sfeldma-mobl.dsl-verizon.net>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

82556 support doesn't work with eepro100, so this removes the ID
(0x1228) for 82556.  See this thread for more info:

http://marc.theaimsgroup.com/?l=linux-kernel&m=110726223221165&w=2

Signed-off-by: Scott Feldman <sfeldma@pobox.com>

--- linux-2.4.28-rc1/drivers/net/eepro100.c.orig	2005-02-01 10:58:56.878906632 -0800
+++ linux-2.4.28-rc1/drivers/net/eepro100.c	2005-02-01 10:59:10.479838976 -0800
@@ -2395,7 +2395,6 @@
 	{ PCI_VENDOR_ID_INTEL, 0x1050, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1059, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1227, PCI_ANY_ID, PCI_ANY_ID, },
-	{ PCI_VENDOR_ID_INTEL, 0x1228, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x2449, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x2459, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x245D, PCI_ANY_ID, PCI_ANY_ID, },
