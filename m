From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/3] sh_eth: cleanup 'enum TD_STS_BIT'
Date: Thu, 20 Jun 2013 02:26:14 +0400
Message-ID: <201306200226.15228.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the comment to 'enum TD_STS_BIT', reformat the values, and add a couple of
values missing before (though unused by the driver).

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo plus the NAPI patches
that I've reposted yesterday.

 drivers/net/ethernet/renesas/sh_eth.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -302,11 +302,11 @@ enum FCFTR_BIT {
 #define DEFAULT_FIFO_F_D_RFF	(FCFTR_RFF2 | FCFTR_RFF1 | FCFTR_RFF0)
 #define DEFAULT_FIFO_F_D_RFD	(FCFTR_RFD2 | FCFTR_RFD1 | FCFTR_RFD0)
 
-/* Transfer descriptor bit */
+/* Transmit descriptor bit */
 enum TD_STS_BIT {
-	TD_TACT = 0x80000000,
-	TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
-	TD_TFP0 = 0x10000000,
+	TD_TACT = 0x80000000, TD_TDLE = 0x40000000,
+	TD_TFP1 = 0x20000000, TD_TFP0 = 0x10000000,
+	TD_TFE  = 0x08000000, TD_TWBI = 0x04000000,
 };
 #define TDF1ST	TD_TFP1
 #define TDFEND	TD_TFP0
