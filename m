From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] Fix the data buffer stashing amount
Date: Mon, 24 Mar 2008 10:53:29 -0500
Message-ID: <1206374009-1292-4-git-send-email-afleming@freescale.com>
References: <1206374009-1292-1-git-send-email-afleming@freescale.com>
 <1206374009-1292-2-git-send-email-afleming@freescale.com>
 <1206374009-1292-3-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:59335 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbYCXPxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 11:53:41 -0400
In-Reply-To: <1206374009-1292-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dai Haruki <dai.haruki@freescale.com>

- Buffer stashing parameter change to 96 from 64 in order to cover the Layer 4 header.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
---
 drivers/net/gianfar.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 119019a..ea8671f 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -102,7 +102,7 @@ extern const char gfar_driver_version[];
 #define DEFAULT_FIFO_TX_STARVE 0x40
 #define DEFAULT_FIFO_TX_STARVE_OFF 0x80
 #define DEFAULT_BD_STASH 1
-#define DEFAULT_STASH_LENGTH	64
+#define DEFAULT_STASH_LENGTH	96
 #define DEFAULT_STASH_INDEX	0
 
 /* The number of Exact Match registers */
-- 
1.5.4.23.gef5b9

