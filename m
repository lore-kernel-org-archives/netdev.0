From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] netdev/phy: mdio-mux-mmioreg.c should include of_address.h
Date: Fri, 7 Sep 2012 15:09:52 -0500
Message-ID: <1347048592-22957-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <sfr@canb.auug.org.au>,
	<rdunlap@xenotime.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mdio-mux-mmioreg.c uses function of_address_to_resource(), which is defined
in linux/of_address.h.  This fixes a compilation error:

drivers/net/phy/mdio-mux-mmioreg.c: In function 'mdio_mux_mmioreg_probe':
drivers/net/phy/mdio-mux-mmioreg.c:83:2: error: implicit declaration of
	function 'of_address_to_resource'

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/phy/mdio-mux-mmioreg.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 098239a..9061ba6 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -12,6 +12,7 @@
 
 #include <linux/platform_device.h>
 #include <linux/device.h>
+#include <linux/of_address.h>
 #include <linux/of_mdio.h>
 #include <linux/module.h>
 #include <linux/init.h>
-- 
1.7.3.4
