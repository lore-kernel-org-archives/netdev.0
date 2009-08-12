From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 31/36] bnx2x: Using PCI_DEVICE macro
Date: Wed, 12 Aug 2009 21:24:10 +0300
Message-ID: <1250101450.27379.183.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754653AbZHLSZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a409767..23b9c7d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -138,12 +138,9 @@ static struct {
 
 
 static const struct pci_device_id bnx2x_pci_tbl[] = {
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57710,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57710 },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711 },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711E,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711E },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711E), BCM57711E },
 	{ 0 }
 };
 
-- 
1.5.4.3




