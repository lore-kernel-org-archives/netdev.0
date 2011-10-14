From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 17/21] stmmac: drop unused Kconfig symbol
Date: Fri, 14 Oct 2011 14:30:32 +0200
Message-ID: <1318595432.6132.76.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/net/stmmac/Kconfig |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 7df7df4..9e37a9a 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -20,15 +20,6 @@ config STMMAC_DA
 	  By default, the DMA arbitration scheme is based on Round-robin
 	  (rx:tx priority is 1:1).
 
-config STMMAC_DUAL_MAC
-	bool "STMMAC: dual mac support (EXPERIMENTAL)"
-	default n
-        depends on EXPERIMENTAL && STMMAC_ETH && !STMMAC_TIMER
-	help
-	  Some ST SoCs (for example the stx7141 and stx7200c2) have two
-	  Ethernet Controllers. This option turns on the second Ethernet
-	  device on this kind of platforms.
-
 config STMMAC_TIMER
 	bool "STMMAC Timer optimisation"
 	default n
-- 
1.7.4.4
