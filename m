From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Subject: [PATCH  3/3] gianfar: Fix bit definitions of IMASK_GRSC and IMASK_GTSC
Date: Wed, 16 Dec 2009 16:45:17 +0530
Message-ID: <1260962117-16892-1-git-send-email-Sandeep.Kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35839 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762043AbZLPLPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 06:15:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---
 drivers/net/gianfar.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 4943cbe..3d72dc4 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -333,7 +333,7 @@ extern const char gfar_driver_version[];
 #define IMASK_BSY               0x20000000
 #define IMASK_EBERR             0x10000000
 #define IMASK_MSRO		0x04000000
-#define IMASK_GRSC              0x02000000
+#define IMASK_GTSC              0x02000000
 #define IMASK_BABT		0x01000000
 #define IMASK_TXC               0x00800000
 #define IMASK_TXEEN		0x00400000
@@ -344,7 +344,7 @@ extern const char gfar_driver_version[];
 #define IMASK_XFUN		0x00010000
 #define IMASK_RXB0              0x00008000
 #define IMASK_MAG		0x00000800
-#define IMASK_GTSC              0x00000100
+#define IMASK_GRSC              0x00000100
 #define IMASK_RXFEN0		0x00000080
 #define IMASK_FIR		0x00000008
 #define IMASK_FIQ		0x00000004
-- 
1.6.5.6

