From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Add new device ids under the Qlogic vendor
Date: Thu, 27 Aug 2015 08:03:08 +0300
Message-ID: <1440651788-22415-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:22258 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751612AbbH0FD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 01:03:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for 3 new PCI device combinations -
1077:16a1, 1077:16a4 and 1077:16ad.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 26fbfcc..e3da2bd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -266,11 +266,14 @@ static const struct pci_device_id bnx2x_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57810_MF), BCM57810_MF },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_O), BCM57840_O },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_4_10), BCM57840_4_10 },
+	{ PCI_VDEVICE(QLOGIC,	PCI_DEVICE_ID_NX2_57840_4_10), BCM57840_4_10 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_2_20), BCM57840_2_20 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57810_VF), BCM57810_VF },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_MFO), BCM57840_MFO },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_MF), BCM57840_MF },
+	{ PCI_VDEVICE(QLOGIC,	PCI_DEVICE_ID_NX2_57840_MF), BCM57840_MF },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_VF), BCM57840_VF },
+	{ PCI_VDEVICE(QLOGIC,	PCI_DEVICE_ID_NX2_57840_VF), BCM57840_VF },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57811), BCM57811 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57811_MF), BCM57811_MF },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57811_VF), BCM57811_VF },
-- 
1.9.3
