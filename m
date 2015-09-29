From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 5/5] net: macmace: Allow modular build
Date: Tue, 29 Sep 2015 10:24:06 +0200
Message-ID: <1443515046-13968-6-git-send-email-geert@linux-m68k.org>
References: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Joshua Thompson <funaho@jurai.org>,
	Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
This depends on "[PATCH 4/5] m68k/mac: Export Peripheral System
Controller (PSC) base address to modules".
---
 drivers/net/ethernet/apple/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apple/Kconfig b/drivers/net/ethernet/apple/Kconfig
index d19a41b0c6d26691..31071297896c96b5 100644
--- a/drivers/net/ethernet/apple/Kconfig
+++ b/drivers/net/ethernet/apple/Kconfig
@@ -51,7 +51,7 @@ config BMAC
 	  will be called bmac.
 
 config MACMACE
-	bool "Macintosh (AV) onboard MACE ethernet"
+	tristate "Macintosh (AV) onboard MACE ethernet"
 	depends on MAC
 	select CRC32
 	---help---
-- 
1.9.1
