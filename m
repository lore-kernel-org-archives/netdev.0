From: Vito Caputo <vcaputo@pengaru.com>
Subject: [PATCH] net: ethernet: aquantia: default to no in config
Date: Tue, 19 Sep 2017 15:43:15 -0700
Message-ID: <20170919224315.GA17797@shells.gnugeneration.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET_VENDOR_AQUANTIA was "default y" for some reason, which seems
obviously inappropriate.
---
 drivers/net/ethernet/aquantia/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/Kconfig b/drivers/net/ethernet/aquantia/Kconfig
index cdf78e069a39..6167b13cf349 100644
--- a/drivers/net/ethernet/aquantia/Kconfig
+++ b/drivers/net/ethernet/aquantia/Kconfig
@@ -4,7 +4,7 @@
 
 config NET_VENDOR_AQUANTIA
 	bool "aQuantia devices"
-	default y
+	default n
 	---help---
 	  Set this to y if you have an Ethernet network cards that uses the aQuantia
 	  AQC107/AQC108 chipset.
-- 
2.11.0
