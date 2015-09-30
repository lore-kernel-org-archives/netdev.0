From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: peak_pci: add unused device id. in devices table
Date: Wed, 30 Sep 2015 13:12:44 +0200
Message-ID: <1443611564-1299-2-git-send-email-mkl@pengutronix.de>
References: <1443611564-1299-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:57327 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbbI3LMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 07:12:48 -0400
In-Reply-To: <1443611564-1299-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Grosjean <s.grosjean@peak-system.com>

While new PEAK_PCIE_OEM_ID has been defined since 3.17, no corresponding
entry has been added in the peak_pci_tbl[] of the peak_pci CAN driver.

This patch enables now users of the PCAN-PCI Express OEM card to run the
peak_pci driver too.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/peak_pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index e5fac368068a..131026fbc2d7 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -87,6 +87,7 @@ static const struct pci_device_id peak_pci_tbl[] = {
 	{PEAK_PCI_VENDOR_ID, PEAK_PC_104P_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_PCI_104E_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_CPCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	{PEAK_PCI_VENDOR_ID, PEAK_PCIE_OEM_ID, PCI_ANY_ID, PCI_ANY_ID,},
 #ifdef CONFIG_CAN_PEAK_PCIEC
 	{PEAK_PCI_VENDOR_ID, PEAK_PCIEC_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_PCIEC34_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
-- 
2.6.0
