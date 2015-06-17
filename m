From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: [PATCH 2/2] net: via/Kconfig: replace USE_OF with OF_???
Date: Wed, 17 Jun 2015 19:42:31 +0800
Message-ID: <1434541351-9699-3-git-send-email-borneo.antonio@gmail.com>
References: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com>
Cc: Antonio Borneo <borneo.antonio@gmail.com>,
	Daniel Lezcano <daniel.lezcano@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

USE_OF is used as intermediate Kconfig option by few
arch's (ARM, MIPS, Xtensa).
Replace instances of USE_OF outside of arch folders
with proper OF_???.

Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
---

 drivers/net/ethernet/via/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index f66ddae..ad7f512 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -19,7 +19,7 @@ if NET_VENDOR_VIA
 
 config VIA_RHINE
 	tristate "VIA Rhine support"
-	depends on (PCI || USE_OF)
+	depends on (PCI || OF_IRQ)
 	select CRC32
 	select MII
 	---help---
@@ -43,7 +43,7 @@ config VIA_RHINE_MMIO
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
-	depends on (PCI || USE_OF)
+	depends on (PCI || (OF_ADDRESS && OF_IRQ))
 	select CRC32
 	select CRC_CCITT
 	select MII
-- 
2.4.3
