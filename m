From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/7] bnxt_en: Add PCI IDs for BCM57454 VF devices.
Date: Mon, 29 May 2017 19:06:05 -0400
Message-ID: <1496099170-701-3-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33712 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdE2XGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:51 -0400
Received: by mail-qk0-f182.google.com with SMTP id y201so56897828qka.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:41 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Khungar <deepak.khungar@broadcom.com>

Signed-off-by: Deepak Khungar <deepak.khungar@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 47bc4f3..dc10a9a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -175,6 +175,8 @@ enum board_idx {
 	{ PCI_VDEVICE(BROADCOM, 0x16f1), .driver_data = BCM57452 },
 	{ PCI_VDEVICE(BROADCOM, 0x1614), .driver_data = BCM57454 },
 #ifdef CONFIG_BNXT_SRIOV
+	{ PCI_VDEVICE(BROADCOM, 0x1606), .driver_data = NETXTREME_E_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x1609), .driver_data = NETXTREME_E_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16c1), .driver_data = NETXTREME_E_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = NETXTREME_C_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16d3), .driver_data = NETXTREME_E_VF },
-- 
1.8.3.1
