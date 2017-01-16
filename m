From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] cpmac: remove hopeless #warning
Date: Mon, 16 Jan 2017 14:20:54 +0100
Message-ID: <20170116132113.2056012-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The #warning was present 10 years ago when the driver first got merged.
As the platform is rather obsolete by now, it seems very unlikely that
the warning will cause anyone to fix the code properly.

kernelci.org reports the warning for every build in the meantime, so
I think it's better to just turn it into a code comment to reduce
noise.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/cpmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 77c88fcf2b86..9b8a30bf939b 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1210,7 +1210,7 @@ int cpmac_init(void)
 		goto fail_alloc;
 	}
 
-#warning FIXME: unhardcode gpio&reset bits
+	/* FIXME: unhardcode gpio&reset bits */
 	ar7_gpio_disable(26);
 	ar7_gpio_disable(27);
 	ar7_device_reset(AR7_RESET_BIT_CPMAC_LO);
-- 
2.9.0
