From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH 1/1] bnx2x: fix 57840_MF pci id
Date: Sun, 26 Aug 2012 13:35:45 +0300
Message-ID: <1345977345-3721-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1629 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab2HZIzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2012 04:55:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c3def943c7117d42caaed3478731ea7c3c87190e have added support for
new pci ids of the 57840 board, while failing to change the obsolete value
in 'pci_ids.h'. 
This patch does so, allowing the probe of such devices.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this correction to 'net'.

Thanks,
Yuval
---
 include/linux/pci_ids.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index fc35260..6b4565c 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2149,7 +2149,7 @@
 #define PCI_DEVICE_ID_TIGON3_5704S	0x16a8
 #define PCI_DEVICE_ID_NX2_57800_VF	0x16a9
 #define PCI_DEVICE_ID_NX2_5706S		0x16aa
-#define PCI_DEVICE_ID_NX2_57840_MF	0x16ab
+#define PCI_DEVICE_ID_NX2_57840_MF	0x16a4
 #define PCI_DEVICE_ID_NX2_5708S		0x16ac
 #define PCI_DEVICE_ID_NX2_57840_VF	0x16ad
 #define PCI_DEVICE_ID_NX2_57810_MF	0x16ae
-- 
1.7.9.rc2
