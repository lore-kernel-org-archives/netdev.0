From: mathieu.poirier@linaro.org
Subject: [PATCH 5/8] 8390: select CRC32 support
Date: Fri, 20 Apr 2012 14:56:13 -0600
Message-ID: <1334955376-17793-6-git-send-email-mathieu.poirier@linaro.org>
References: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The ax88796 driver uses the CRC32 functions, so make sure that
they are actually enabled.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/ethernet/8390/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index e04ade4..910895c 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -60,6 +60,7 @@ config PCMCIA_AXNET
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
 	depends on (ARM || MIPS || SUPERH)
+	select CRC32
 	select PHYLIB
 	select MDIO_BITBANG
 	---help---
-- 
1.7.5.4
