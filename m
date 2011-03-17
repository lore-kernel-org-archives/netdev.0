From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-dev2.6] bxn2x: Fix location of PCI-ids defines
Date: Thu, 17 Mar 2011 14:27:04 +0200
Message-ID: <1300364824.2090.57.camel@lb-tlvb-ariel.il.broadcom.com>
Reply-To: ariele@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3368 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753768Ab1CQMVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 08:21:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    7 -------
 include/linux/pci_ids.h        |    2 ++
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c
b/drivers/net/bnx2x/bnx2x_main.c
index 10bc0a6..ab2fc65 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -145,13 +145,6 @@ static struct {
 	{ "Broadcom NetXtreme II BCM57712E XGb" }
 };
 
-#ifndef PCI_DEVICE_ID_NX2_57712
-#define PCI_DEVICE_ID_NX2_57712		0x1662
-#endif
-#ifndef PCI_DEVICE_ID_NX2_57712E
-#define PCI_DEVICE_ID_NX2_57712E	0x1663
-#endif
-
 static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 3adb06e..f82986b 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2078,6 +2078,8 @@
 #define PCI_DEVICE_ID_TIGON3_5723	0x165b
 #define PCI_DEVICE_ID_TIGON3_5705M	0x165d
 #define PCI_DEVICE_ID_TIGON3_5705M_2	0x165e
+#define PCI_DEVICE_ID_NX2_57712		0x1662
+#define PCI_DEVICE_ID_NX2_57712E	0x1663
 #define PCI_DEVICE_ID_TIGON3_5714	0x1668
 #define PCI_DEVICE_ID_TIGON3_5714S	0x1669
 #define PCI_DEVICE_ID_TIGON3_5780	0x166a
-- 
1.7.4.1




