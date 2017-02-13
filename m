From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 9/9] bnxt_en: Added PCI IDs for BCM57452 and BCM57454 ASICs
Date: Sun, 12 Feb 2017 19:18:18 -0500
Message-ID: <1486945098-4086-10-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38529 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdBMATD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:19:03 -0500
Received: by mail-it0-f45.google.com with SMTP id c7so62058234itd.1
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:19:03 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Khungar <deepak.khungar@broadcom.com>

Signed-off-by: Deepak Khungar <deepak.khungar@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c899d61..71f9a18 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -99,6 +99,8 @@ enum board_idx {
 	BCM57407_NPAR,
 	BCM57414_NPAR,
 	BCM57416_NPAR,
+	BCM57452,
+	BCM57454,
 	NETXTREME_E_VF,
 	NETXTREME_C_VF,
 };
@@ -133,6 +135,8 @@ enum board_idx {
 	{ "Broadcom BCM57407 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57414 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57416 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57452 NetXtreme-E 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57454 NetXtreme-E 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
 	{ "Broadcom NetXtreme-E Ethernet Virtual Function" },
 	{ "Broadcom NetXtreme-C Ethernet Virtual Function" },
 };
@@ -168,6 +172,8 @@ enum board_idx {
 	{ PCI_VDEVICE(BROADCOM, 0x16ed), .driver_data = BCM57414_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16ee), .driver_data = BCM57416_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16ef), .driver_data = BCM57416_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16f1), .driver_data = BCM57452 },
+	{ PCI_VDEVICE(BROADCOM, 0x1614), .driver_data = BCM57454 },
 #ifdef CONFIG_BNXT_SRIOV
 	{ PCI_VDEVICE(BROADCOM, 0x16c1), .driver_data = NETXTREME_E_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = NETXTREME_C_VF },
-- 
1.8.3.1
