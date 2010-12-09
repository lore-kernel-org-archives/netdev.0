From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 6/8] bnx2x: replace FW to 6.2.5
Date: Thu, 9 Dec 2010 14:15:35 +0200
Message-ID: <1291896935.8745.13.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1503 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755220Ab0LIMVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 07:21:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Includes FCoE related fixes in FW flows

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h |    4 ++--
 firmware/Makefile             |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index ed90ec8..6238d4f 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -1832,8 +1832,8 @@ struct host_func_stats {
 
 
 #define BCM_5710_FW_MAJOR_VERSION			6
-#define BCM_5710_FW_MINOR_VERSION			0
-#define BCM_5710_FW_REVISION_VERSION			34
+#define BCM_5710_FW_MINOR_VERSION			2
+#define BCM_5710_FW_REVISION_VERSION			5
 #define BCM_5710_FW_ENGINEERING_VERSION			0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
diff --git a/firmware/Makefile b/firmware/Makefile
index 74d47cd..69779d1 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -32,9 +32,9 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
-fw-shipped-$(CONFIG_BNX2X) += bnx2x/bnx2x-e1-6.0.34.0.fw \
-			      bnx2x/bnx2x-e1h-6.0.34.0.fw \
-			      bnx2x/bnx2x-e2-6.0.34.0.fw
+fw-shipped-$(CONFIG_BNX2X) += bnx2x/bnx2x-e1-6.2.5.0.fw \
+			      bnx2x/bnx2x-e1h-6.2.5.0.fw \
+			      bnx2x/bnx2x-e2-6.2.5.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-6.0.17.fw \
 			     bnx2/bnx2-rv2p-09-6.0.17.fw \
 			     bnx2/bnx2-rv2p-09ax-6.0.17.fw \
-- 
1.7.1




