From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 02/18] bnx2x: Misleading name
Date: Mon, 02 Mar 2009 19:59:20 +0200
Message-ID: <1236016760.7723.73.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ben Hutchings" <bhutchings@solarflare.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3946 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536AbZCBSAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 02/18] bnx2x: Misleading name

As noted by Ben Hutchings <bhutchings@solarflare.com>, these are the
capabilities offsets and not the ID itself

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_reg.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 360a256..8de80cc 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5410,7 +5410,7 @@
 #define PCICFG_COMMAND_INT_DISABLE		(1<<10)
 #define PCICFG_COMMAND_RESERVED 		(0x1f<<11)
 #define PCICFG_STATUS_OFFSET				0x06
-#define PCICFG_REVESION_ID				0x08
+#define PCICFG_REVESION_ID_OFFSET			0x08
 #define PCICFG_CACHE_LINE_SIZE				0x0c
 #define PCICFG_LATENCY_TIMER				0x0d
 #define PCICFG_BAR_1_LOW				0x10
@@ -5438,7 +5438,7 @@
 #define PCICFG_PM_CSR_STATE			(0x3<<0)
 #define PCICFG_PM_CSR_PME_ENABLE		(1<<8)
 #define PCICFG_PM_CSR_PME_STATUS		(1<<15)
-#define PCICFG_MSI_CAP_ID				0x58
+#define PCICFG_MSI_CAP_ID_OFFSET			0x58
 #define PCICFG_MSI_CONTROL_ENABLE		(0x1<<16)
 #define PCICFG_MSI_CONTROL_MCAP 		(0x7<<17)
 #define PCICFG_MSI_CONTROL_MENA 		(0x7<<20)
@@ -5446,7 +5446,7 @@
 #define PCICFG_MSI_CONTROL_MSI_PVMASK_CAPABLE	(0x1<<24)
 #define PCICFG_GRC_ADDRESS				0x78
 #define PCICFG_GRC_DATA 				0x80
-#define PCICFG_MSIX_CAP_ID				0xa0
+#define PCICFG_MSIX_CAP_ID_OFFSET			0xa0
 #define PCICFG_MSIX_CONTROL_TABLE_SIZE		(0x7ff<<16)
 #define PCICFG_MSIX_CONTROL_RESERVED		(0x7<<27)
 #define PCICFG_MSIX_CONTROL_FUNC_MASK		(0x1<<30)
-- 
1.5.4.3




