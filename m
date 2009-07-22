From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] net: KS8851 needs to depend on MII
Date: Wed, 22 Jul 2009 15:16:51 +0400
Message-ID: <1248261411-12533-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: linux-next@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, ben@simtec.co.uk
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix this build error when CONFIG_MII is not set
drivers/net/ks8851.c:999: undefined reference to `generic_mii_ioctl'
drivers/net/ks8851.c:1050: undefined reference to `mii_link_ok'
drivers/net/ks8851.c:1056: undefined reference to `mii_nway_restart'
drivers/net/ks8851.c:1044: undefined reference to `mii_ethtool_sset'
drivers/net/ks8851.c:1038: undefined reference to `mii_ethtool_gset'

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1dbaffd..3ed49f1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1732,6 +1732,7 @@ config KS8842
 config KS8851
        tristate "Micrel KS8851 SPI"
        depends on SPI
+       select MII
        help
          SPI driver for Micrel KS8851 SPI attached network chip.
 
-- 
1.6.3.3
