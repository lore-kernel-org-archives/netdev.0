From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/14] bnxt_en: adding PCI ID for SMARTNIC VF support
Date: Thu, 26 Oct 2017 11:51:21 -0400
Message-ID: <1509033092-1887-4-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Rob Miller <rmiller@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:45900 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932425AbdJZPvt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:49 -0400
Received: by mail-qt0-f194.google.com with SMTP id p1so4883021qtg.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:49 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Miller <rmiller@broadcom.com>

Signed-off-by: Rob Miller <rmiller@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a9db4e6..d2403f4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -112,6 +112,7 @@ enum board_idx {
 	BCM58808,
 	NETXTREME_E_VF,
 	NETXTREME_C_VF,
+	NETXTREME_S_VF,
 };
 
 /* indexed by enum above */
@@ -151,6 +152,7 @@ enum board_idx {
 	[BCM58808] = { "Broadcom BCM58808 NetXtreme-S 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
 	[NETXTREME_E_VF] = { "Broadcom NetXtreme-E Ethernet Virtual Function" },
 	[NETXTREME_C_VF] = { "Broadcom NetXtreme-C Ethernet Virtual Function" },
+	[NETXTREME_S_VF] = { "Broadcom NetXtreme-S Ethernet Virtual Function" },
 };
 
 static const struct pci_device_id bnxt_pci_tbl[] = {
@@ -198,6 +200,7 @@ enum board_idx {
 	{ PCI_VDEVICE(BROADCOM, 0x16dc), .driver_data = NETXTREME_E_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16e1), .driver_data = NETXTREME_C_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16e5), .driver_data = NETXTREME_C_VF },
+	{ PCI_VDEVICE(BROADCOM, 0xd800), .driver_data = NETXTREME_S_VF },
 #endif
 	{ 0 }
 };
@@ -222,7 +225,8 @@ enum board_idx {
 
 static bool bnxt_vf_pciid(enum board_idx idx)
 {
-	return (idx == NETXTREME_C_VF || idx == NETXTREME_E_VF);
+	return (idx == NETXTREME_C_VF || idx == NETXTREME_E_VF ||
+		idx == NETXTREME_S_VF);
 }
 
 #define DB_CP_REARM_FLAGS	(DB_KEY_CP | DB_IDX_VALID)
-- 
1.8.3.1
