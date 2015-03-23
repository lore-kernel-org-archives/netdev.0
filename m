From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH net-next 1/3] bgmac: fix descriptor frame start/end definitions
Date: Mon, 23 Mar 2015 12:35:35 +0100
Message-ID: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:51357
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752497AbbCWLv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:51:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The start-of-frame and end-of-frame bits were accidentally swapped.
In the current code it does not make any difference, since they are
always used together.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 89fa5bc..1f9f36f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -345,8 +345,8 @@
 
 #define BGMAC_DESC_CTL0_EOT			0x10000000	/* End of ring */
 #define BGMAC_DESC_CTL0_IOC			0x20000000	/* IRQ on complete */
-#define BGMAC_DESC_CTL0_SOF			0x40000000	/* Start of frame */
-#define BGMAC_DESC_CTL0_EOF			0x80000000	/* End of frame */
+#define BGMAC_DESC_CTL0_EOF			0x40000000	/* End of frame */
+#define BGMAC_DESC_CTL0_SOF			0x80000000	/* Start of frame */
 #define BGMAC_DESC_CTL1_LEN			0x00001FFF
 
 #define BGMAC_PHY_NOREGS			0x1E
-- 
2.2.2
