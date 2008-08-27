From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND] [NET-NEXT PATCH 1/3] e1000e: add support for the 82567LM-4
	device
Date: Tue, 26 Aug 2008 18:36:36 -0700
Message-ID: <20080827013611.5716.7376.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, andy@greyhouse.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:49184 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbYH0Bgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 21:36:39 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2401901rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 18:36:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Enable PCI device ID for a new combination of MAC and PHY already supported
in the driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |    1 +
 drivers/net/e1000e/netdev.c  |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 74f263a..d0e7b46 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -346,6 +346,7 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH8_IFE_G			0x10C5
 #define E1000_DEV_ID_ICH8_IGP_M			0x104D
 #define E1000_DEV_ID_ICH9_IGP_AMT		0x10BD
+#define E1000_DEV_ID_ICH9_BM			0x10E5
 #define E1000_DEV_ID_ICH9_IGP_M_AMT		0x10F5
 #define E1000_DEV_ID_ICH9_IGP_M			0x10BF
 #define E1000_DEV_ID_ICH9_IGP_M_V		0x10CB
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 9e38452..b5fc2c9 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -44,6 +44,7 @@
  * 82567LF-2 Gigabit Network Connection
  * 82567V-2 Gigabit Network Connection
  * 82562GT-3 10/100 Network Connection
+ * 82567LM-4 Gigabit Network Connection
  */
 
 #include <linux/netdevice.h>
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d266510..c3d7411 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4767,6 +4767,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_AMT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_C), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_BM), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_AMT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_V), board_ich9lan },

