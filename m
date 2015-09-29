From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 3/5] net: hplance: Allow modular build
Date: Tue, 29 Sep 2015 10:24:04 +0200
Message-ID: <1443515046-13968-4-git-send-email-geert@linux-m68k.org>
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
 drivers/net/ethernet/amd/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index afc62ea804fc35d4..0038709fd317d83c 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -100,7 +100,7 @@ config DECLANCE
 	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
 
 config HPLANCE
-	bool "HP on-board LANCE support"
+	tristate "HP on-board LANCE support"
 	depends on DIO
 	select CRC32
 	---help---
-- 
1.9.1
