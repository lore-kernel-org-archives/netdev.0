From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: macb: Correct the MID field length value
Date: Thu,  5 Mar 2015 15:02:10 +0100
Message-ID: <781b35c13921854b0a8d860b727f8ac86147768a.1425564128.git.michal.simek@xilinx.com>
Cc: Zach Pfeffer <zachp@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>

The latest spec "I-IPA01-0266-USR Rev 10" limit the MID field length to 12 bit
value. For previous versions it is 16 bit value.

This change will not break the backward compatibility as the latest ID value is
7 and with in the 12 bit value limit.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 57f0a1a7415d..6cfff0b04d05 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -352,7 +352,7 @@
 
 /* Bitfields in MID */
 #define MACB_IDNUM_OFFSET			16
-#define MACB_IDNUM_SIZE				16
+#define MACB_IDNUM_SIZE				12
 #define MACB_REV_OFFSET				0
 #define MACB_REV_SIZE				16
 
-- 
1.8.2.3
