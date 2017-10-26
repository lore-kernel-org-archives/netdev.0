From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/14] bnxt_en: Add PCIe device ID for bcm58804
Date: Thu, 26 Oct 2017 11:51:20 -0400
Message-ID: <1509033092-1887-3-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Ray Jui <ray.jui@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:53539 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932255AbdJZPvs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:48 -0400
Received: by mail-qt0-f193.google.com with SMTP id n61so4856430qte.10
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:48 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ray Jui <ray.jui@broadcom.com>

Add new PCIe device ID and chip number for bcm58804

Signed-off-by: Ray Jui <ray.jui@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 24d55724..a9db4e6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -108,6 +108,7 @@ enum board_idx {
 	BCM57452,
 	BCM57454,
 	BCM58802,
+	BCM58804,
 	BCM58808,
 	NETXTREME_E_VF,
 	NETXTREME_C_VF,
@@ -146,6 +147,7 @@ enum board_idx {
 	[BCM57452] = { "Broadcom BCM57452 NetXtreme-E 10Gb/25Gb/40Gb/50Gb Ethernet" },
 	[BCM57454] = { "Broadcom BCM57454 NetXtreme-E 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
 	[BCM58802] = { "Broadcom BCM58802 NetXtreme-S 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	[BCM58804] = { "Broadcom BCM58804 NetXtreme-S 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
 	[BCM58808] = { "Broadcom BCM58808 NetXtreme-S 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
 	[NETXTREME_E_VF] = { "Broadcom NetXtreme-E Ethernet Virtual Function" },
 	[NETXTREME_C_VF] = { "Broadcom NetXtreme-C Ethernet Virtual Function" },
@@ -186,6 +188,7 @@ enum board_idx {
 	{ PCI_VDEVICE(BROADCOM, 0x16f0), .driver_data = BCM58808 },
 	{ PCI_VDEVICE(BROADCOM, 0x16f1), .driver_data = BCM57452 },
 	{ PCI_VDEVICE(BROADCOM, 0xd802), .driver_data = BCM58802 },
+	{ PCI_VDEVICE(BROADCOM, 0xd804), .driver_data = BCM58804 },
 #ifdef CONFIG_BNXT_SRIOV
 	{ PCI_VDEVICE(BROADCOM, 0x1606), .driver_data = NETXTREME_E_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x1609), .driver_data = NETXTREME_E_VF },
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index c911e69..d193923 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1013,6 +1013,7 @@ struct bnxt {
 #define CHIP_NUM_5745X		0xd730
 
 #define CHIP_NUM_58802		0xd802
+#define CHIP_NUM_58804		0xd804
 #define CHIP_NUM_58808		0xd808
 
 #define BNXT_CHIP_NUM_5730X(chip_num)		\
@@ -1048,6 +1049,7 @@ struct bnxt {
 
 #define BNXT_CHIP_NUM_588XX(chip_num)		\
 	((chip_num) == CHIP_NUM_58802 ||	\
+	 (chip_num) == CHIP_NUM_58804 ||        \
 	 (chip_num) == CHIP_NUM_58808)
 
 	struct net_device	*dev;
-- 
1.8.3.1
