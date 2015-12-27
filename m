From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 12/12] bnxt_en: Add BCM57301 & BCM57402 devices.
Date: Sun, 27 Dec 2015 18:19:29 -0500
Message-ID: <1451258369-21543-13-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:65238 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829AbbL0XTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:33 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Christensen <davidch@broadcom.com>

Added the PCI IDs for the BCM57301 and BCM57402 controllers.

Signed-off-by: David Christensen <davidch@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 52dfaab..319653a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -72,8 +72,10 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 #define BNXT_TX_PUSH_THRESH 92
 
 enum board_idx {
+	BCM57301,
 	BCM57302,
 	BCM57304,
+	BCM57402,
 	BCM57404,
 	BCM57406,
 	BCM57304_VF,
@@ -84,17 +86,21 @@ enum board_idx {
 static const struct {
 	char *name;
 } board_info[] = {
-	{ "Broadcom BCM57302 NetXtreme-C Single-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57301 NetXtreme-C Single-port 10Gb Ethernet" },
+	{ "Broadcom BCM57302 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57402 NetXtreme-E Dual-port 10Gb Ethernet" },
 	{ "Broadcom BCM57404 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
-	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10Gb Ethernet" },
+	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10GBase-T Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Ethernet Virtual Function" },
 	{ "Broadcom BCM57404 NetXtreme-E Ethernet Virtual Function" },
 };
 
 static const struct pci_device_id bnxt_pci_tbl[] = {
+	{ PCI_VDEVICE(BROADCOM, 0x16c8), .driver_data = BCM57301 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c9), .driver_data = BCM57302 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ca), .driver_data = BCM57304 },
+	{ PCI_VDEVICE(BROADCOM, 0x16d0), .driver_data = BCM57402 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d1), .driver_data = BCM57404 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d2), .driver_data = BCM57406 },
 #ifdef CONFIG_BNXT_SRIOV
-- 
1.8.3.1
