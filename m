From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 02/75] solos-pci: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:40:32 +0000
Message-ID: <1257630032.15927.377.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46892 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752924AbZKGVnP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:43:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/atm/solos-pci.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c5f5186..d7ad19d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -142,6 +142,9 @@ MODULE_AUTHOR("Traverse Technologies <support@traverse.com.au>");
 MODULE_DESCRIPTION("Solos PCI driver");
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE("solos-FPGA.bin");
+MODULE_FIRMWARE("solos-Firmware.bin");
+MODULE_FIRMWARE("solos-db-FPGA.bin");
 MODULE_PARM_DESC(reset, "Reset Solos chips on startup");
 MODULE_PARM_DESC(atmdebug, "Print ATM data");
 MODULE_PARM_DESC(firmware_upgrade, "Initiate Solos firmware upgrade");
-- 
1.6.5.2



