From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 04/19] bnx2x: create folder for bnx2x firmware
 files
Date: Wed, 6 Oct 2010 15:18:47 +0200
Message-ID: <1286371127.30552.21.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab0JFNj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c                  |    4 ++--
 firmware/Makefile                               |    3 ++-
 firmware/WHENCE                                 |    4 ++--
 firmware/{ => bnx2x}/bnx2x-e1-5.2.13.0.fw.ihex  |    0
 firmware/{ => bnx2x}/bnx2x-e1h-5.2.13.0.fw.ihex |    0
 5 files changed, 6 insertions(+), 5 deletions(-)
 rename firmware/{ => bnx2x}/bnx2x-e1-5.2.13.0.fw.ihex (100%)
 rename firmware/{ => bnx2x}/bnx2x-e1h-5.2.13.0.fw.ihex (100%)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 67587fe..3696a4b 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -66,8 +66,8 @@
 	__stringify(BCM_5710_FW_MINOR_VERSION) "."	\
 	__stringify(BCM_5710_FW_REVISION_VERSION) "."	\
 	__stringify(BCM_5710_FW_ENGINEERING_VERSION)
-#define FW_FILE_NAME_E1		"bnx2x-e1-" FW_FILE_VERSION ".fw"
-#define FW_FILE_NAME_E1H	"bnx2x-e1h-" FW_FILE_VERSION ".fw"
+#define FW_FILE_NAME_E1		"bnx2x/bnx2x-e1-" FW_FILE_VERSION ".fw"
+#define FW_FILE_NAME_E1H	"bnx2x/bnx2x-e1h-" FW_FILE_VERSION ".fw"
 
 /* Time in jiffies before concluding the transmitter is hung */
 #define TX_TIMEOUT		(5*HZ)
diff --git a/firmware/Makefile b/firmware/Makefile
index 9c2d194..44b3aae 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -32,7 +32,8 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
-fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-5.2.13.0.fw bnx2x-e1h-5.2.13.0.fw
+fw-shipped-$(CONFIG_BNX2X) += bnx2x/bnx2x-e1-5.2.13.0.fw \
+			      bnx2x/bnx2x-e1h-5.2.13.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-5.0.0.j15.fw \
 			     bnx2/bnx2-rv2p-09-5.0.0.j10.fw \
 			     bnx2/bnx2-rv2p-09ax-5.0.0.j10.fw \
diff --git a/firmware/WHENCE b/firmware/WHENCE
index ae5f8a4..1d3936c 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -679,8 +679,8 @@ Found in hex form in kernel source.
 
 Driver: bnx2x: Broadcom Everest
 
-File: bnx2x-e1-5.2.13.0.fw
-File: bnx2x-e1h-5.2.13.0.fw
+File: bnx2x/bnx2x-e1-5.2.13.0.fw
+File: bnx2x/bnx2x-e1h-5.2.13.0.fw
 
 License:
   Copyright (c) 2007-2010 Broadcom Corporation
diff --git a/firmware/bnx2x-e1-5.2.13.0.fw.ihex b/firmware/bnx2x/bnx2x-e1-5.2.13.0.fw.ihex
similarity index 100%
rename from firmware/bnx2x-e1-5.2.13.0.fw.ihex
rename to firmware/bnx2x/bnx2x-e1-5.2.13.0.fw.ihex
diff --git a/firmware/bnx2x-e1h-5.2.13.0.fw.ihex b/firmware/bnx2x/bnx2x-e1h-5.2.13.0.fw.ihex
similarity index 100%
rename from firmware/bnx2x-e1h-5.2.13.0.fw.ihex
rename to firmware/bnx2x/bnx2x-e1h-5.2.13.0.fw.ihex
-- 
1.7.1




