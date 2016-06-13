From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 09/11] bnxt_en: Add BCM5731X and BCM5741X device IDs.
Date: Mon, 13 Jun 2016 02:25:36 -0400
Message-ID: <1465799138-27529-10-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34622 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030183AbcFMGZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:59 -0400
Received: by mail-pa0-f43.google.com with SMTP id bz2so42651602pad.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:59 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5f9285c..c275329 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -75,13 +75,22 @@ enum board_idx {
 	BCM57301,
 	BCM57302,
 	BCM57304,
+	BCM57311,
+	BCM57312,
 	BCM57402,
 	BCM57404,
 	BCM57406,
 	BCM57404_NPAR,
+	BCM57412,
+	BCM57414,
+	BCM57416,
+	BCM57417,
+	BCM57414_NPAR,
 	BCM57314,
 	BCM57304_VF,
 	BCM57404_VF,
+	BCM57414_VF,
+	BCM57314_VF,
 };
 
 /* indexed by enum above */
@@ -91,27 +100,45 @@ static const struct {
 	{ "Broadcom BCM57301 NetXtreme-C Single-port 10Gb Ethernet" },
 	{ "Broadcom BCM57302 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57311 NetXtreme-C Single-port 10Gb Ethernet" },
+	{ "Broadcom BCM57312 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57402 NetXtreme-E Dual-port 10Gb Ethernet" },
 	{ "Broadcom BCM57404 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10GBase-T Ethernet" },
 	{ "Broadcom BCM57404 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57412 NetXtreme-E Dual-port 10Gb Ethernet" },
+	{ "Broadcom BCM57414 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57416 NetXtreme-E Dual-port 10GBase-T Ethernet" },
+	{ "Broadcom BCM57417 NetXtreme-E Dual-port 10GBase-T Ethernet" },
+	{ "Broadcom BCM57414 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57314 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Ethernet Virtual Function" },
 	{ "Broadcom BCM57404 NetXtreme-E Ethernet Virtual Function" },
+	{ "Broadcom BCM57414 NetXtreme-E Ethernet Virtual Function" },
+	{ "Broadcom BCM57314 NetXtreme-E Ethernet Virtual Function" },
 };
 
 static const struct pci_device_id bnxt_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, 0x16c8), .driver_data = BCM57301 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c9), .driver_data = BCM57302 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ca), .driver_data = BCM57304 },
+	{ PCI_VDEVICE(BROADCOM, 0x16ce), .driver_data = BCM57311 },
+	{ PCI_VDEVICE(BROADCOM, 0x16cf), .driver_data = BCM57312 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d0), .driver_data = BCM57402 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d1), .driver_data = BCM57404 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d2), .driver_data = BCM57406 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d4), .driver_data = BCM57404_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16d6), .driver_data = BCM57412 },
+	{ PCI_VDEVICE(BROADCOM, 0x16d7), .driver_data = BCM57414 },
+	{ PCI_VDEVICE(BROADCOM, 0x16d8), .driver_data = BCM57416 },
+	{ PCI_VDEVICE(BROADCOM, 0x16d9), .driver_data = BCM57417 },
+	{ PCI_VDEVICE(BROADCOM, 0x16de), .driver_data = BCM57414_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16df), .driver_data = BCM57314 },
 #ifdef CONFIG_BNXT_SRIOV
 	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = BCM57304_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16d3), .driver_data = BCM57404_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16dc), .driver_data = BCM57414_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16e1), .driver_data = BCM57314_VF },
 #endif
 	{ 0 }
 };
@@ -134,7 +161,8 @@ static const u16 bnxt_async_events_arr[] = {
 
 static bool bnxt_vf_pciid(enum board_idx idx)
 {
-	return (idx == BCM57304_VF || idx == BCM57404_VF);
+	return (idx == BCM57304_VF || idx == BCM57404_VF ||
+		idx == BCM57314_VF || idx == BCM57414_VF);
 }
 
 #define DB_CP_REARM_FLAGS	(DB_KEY_CP | DB_IDX_VALID)
-- 
1.8.3.1
