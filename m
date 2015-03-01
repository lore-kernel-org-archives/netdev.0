From: Arun Chandran <achandran@mvista.com>
Subject: [PATCH 2/2] net: macb: Properly add DMACFG bit definitions
Date: Sun,  1 Mar 2015 11:38:03 +0530
Message-ID: <1425190083-16007-2-git-send-email-achandran@mvista.com>
References: <20150227.172430.705343480463996651.davem@davemloft.net>
 <1425190083-16007-1-git-send-email-achandran@mvista.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Arun Chandran <achandran@mvista.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425190083-16007-1-git-send-email-achandran@mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add *_SIZE macros for the bits ENDIA_DESC and
ENDIA_PKT

Signed-off-by: Arun Chandran <achandran@mvista.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
* Correct these macros according to comments from Nicolas Ferre. Also add his Acked-by
---
---
 drivers/net/ethernet/cadence/macb.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 57f0a1a..83241c8 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -230,8 +230,9 @@
 #define GEM_FBLDO_OFFSET	0 /* fixed burst length for DMA */
 #define GEM_FBLDO_SIZE		5
 #define GEM_ENDIA_DESC_OFFSET	6 /* endian swap mode for management descriptor access */
+#define GEM_ENDIA_DESC_SIZE	1
 #define GEM_ENDIA_PKT_OFFSET	7 /* endian swap mode for packet data access */
-#define GEM_ENDIA_SIZE		1
+#define GEM_ENDIA_PKT_SIZE	1
 #define GEM_RXBMS_OFFSET	8 /* RX packet buffer memory size select */
 #define GEM_RXBMS_SIZE		2
 #define GEM_TXPBMS_OFFSET	10 /* TX packet buffer memory size select */
-- 
1.9.1
