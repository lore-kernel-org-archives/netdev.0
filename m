From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 8/9] bnxt_en: Add BCM57314 device ID.
Date: Sun, 15 May 2016 03:04:50 -0400
Message-ID: <1463295891-15216-9-git-send-email-michael.chan@broadcom.com>
References: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35104 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbcEOHFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:05:10 -0400
Received: by mail-pa0-f48.google.com with SMTP id iv1so54189966pac.2
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:05:09 -0700 (PDT)
In-Reply-To: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
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
