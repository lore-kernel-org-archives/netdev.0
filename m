From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 8/9] bnxt_en: Add BCM57314 device ID.
Date: Sat, 14 May 2016 20:29:47 -0400
Message-ID: <1463272188-30025-9-git-send-email-michael.chan@broadcom.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36688 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbcEOAaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:30:06 -0400
Received: by mail-pf0-f169.google.com with SMTP id c189so56579849pfb.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:30:05 -0700 (PDT)
In-Reply-To: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6def145..f2ac7da 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -78,6 +78,7 @@ enum board_idx {
 	BCM57402,
 	BCM57404,
 	BCM57406,
+	BCM57314,
 	BCM57304_VF,
 	BCM57404_VF,
 };
@@ -92,6 +93,7 @@ static const struct {
 	{ "Broadcom BCM57402 NetXtreme-E Dual-port 10Gb Ethernet" },
 	{ "Broadcom BCM57404 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10GBase-T Ethernet" },
+	{ "Broadcom BCM57314 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Ethernet Virtual Function" },
 	{ "Broadcom BCM57404 NetXtreme-E Ethernet Virtual Function" },
 };
@@ -103,6 +105,7 @@ static const struct pci_device_id bnxt_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, 0x16d0), .driver_data = BCM57402 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d1), .driver_data = BCM57404 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d2), .driver_data = BCM57406 },
+	{ PCI_VDEVICE(BROADCOM, 0x16df), .driver_data = BCM57314 },
 #ifdef CONFIG_BNXT_SRIOV
 	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = BCM57304_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16d3), .driver_data = BCM57404_VF },
-- 
1.8.3.1
