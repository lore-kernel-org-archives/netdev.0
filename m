From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/12] e1000e: add PCI device id to enable
	support for 82567V-4
Date: Mon, 10 May 2010 18:02:52 -0700
Message-ID: <20100511010250.30827.86831.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:43878 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758077Ab0EKBDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:03:10 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h     |    1 +
 drivers/net/e1000e/netdev.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index fa314b4..5d1220d 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -382,6 +382,7 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH10_R_BM_V		0x10CE
 #define E1000_DEV_ID_ICH10_D_BM_LM		0x10DE
 #define E1000_DEV_ID_ICH10_D_BM_LF		0x10DF
+#define E1000_DEV_ID_ICH10_D_BM_V		0x1525
 #define E1000_DEV_ID_PCH_M_HV_LM		0x10EA
 #define E1000_DEV_ID_PCH_M_HV_LC		0x10EB
 #define E1000_DEV_ID_PCH_D_HV_DM		0x10EF
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d1f60c5..1ad29d9 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5894,6 +5894,7 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_LM), board_ich10lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_LF), board_ich10lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_V), board_ich10lan },
 
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_M_HV_LM), board_pchlan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_M_HV_LC), board_pchlan },

