From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/12] sfc: Rename falcon.h to nic.h
Date: Mon, 30 Nov 2009 01:12:08 +0000
Message-ID: <1259543528.3709.90.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46719 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZK3BMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:12:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nic.h is no longer specific to Falcon.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c               |    2 +-
 drivers/net/sfc/ethtool.c           |    2 +-
 drivers/net/sfc/falcon.c            |    2 +-
 drivers/net/sfc/falcon_boards.c     |    2 +-
 drivers/net/sfc/falcon_gmac.c       |    2 +-
 drivers/net/sfc/falcon_xmac.c       |    2 +-
 drivers/net/sfc/mdio_10g.c          |    2 +-
 drivers/net/sfc/mtd.c               |    2 +-
 drivers/net/sfc/{falcon.h => nic.h} |    6 +++---
 drivers/net/sfc/qt202x_phy.c        |    2 +-
 drivers/net/sfc/rx.c                |    2 +-
 drivers/net/sfc/selftest.c          |    2 +-
 drivers/net/sfc/tenxpress.c         |    2 +-
 drivers/net/sfc/tx.c                |    2 +-
 14 files changed, 16 insertions(+), 16 deletions(-)
 rename drivers/net/sfc/{falcon.h => nic.h} (99%)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c49d364..97a6ebd 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -23,7 +23,7 @@
 #include "net_driver.h"
 #include "efx.h"
 #include "mdio_10g.h"
-#include "falcon.h"
+#include "nic.h"
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0a79ec7..012ee31 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -15,7 +15,7 @@
 #include "workarounds.h"
 #include "selftest.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "spi.h"
 #include "mdio_10g.h"
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index f77bbbe..64b47da 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -20,7 +20,7 @@
 #include "efx.h"
 #include "mac.h"
 #include "spi.h"
-#include "falcon.h"
+#include "nic.h"
 #include "regs.h"
 #include "io.h"
 #include "mdio_10g.h"
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index b92decc..fa4d4c7 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -12,7 +12,7 @@
 #include "net_driver.h"
 #include "phy.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "regs.h"
 #include "io.h"
 #include "workarounds.h"
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 19dd3ac..aa9b689 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -11,7 +11,7 @@
 #include <linux/delay.h>
 #include "net_driver.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "mac.h"
 #include "regs.h"
 #include "io.h"
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 643622d..cd63f24 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -11,7 +11,7 @@
 #include <linux/delay.h>
 #include "net_driver.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "regs.h"
 #include "io.h"
 #include "mac.h"
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 20e6274..19496da 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -15,7 +15,7 @@
 #include "net_driver.h"
 #include "mdio_10g.h"
 #include "workarounds.h"
-#include "falcon.h"
+#include "nic.h"
 
 unsigned efx_mdio_id_oui(u32 id)
 {
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index 3121e24..65a22f1 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -17,7 +17,7 @@
 #include "net_driver.h"
 #include "spi.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 
 #define EFX_SPI_VERIFY_BUF_LEN 16
 
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/nic.h
similarity index 99%
rename from drivers/net/sfc/falcon.h
rename to drivers/net/sfc/nic.h
index 3085ecf..e7eb304 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/nic.h
@@ -8,8 +8,8 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
-#ifndef EFX_FALCON_H
-#define EFX_FALCON_H
+#ifndef EFX_NIC_H
+#define EFX_NIC_H
 
 #include <linux/i2c-algo-bit.h>
 #include "net_driver.h"
@@ -235,4 +235,4 @@ extern void efx_nic_generate_event(struct efx_channel *channel,
 
 extern void falcon_poll_xmac(struct efx_nic *efx);
 
-#endif /* EFX_FALCON_H */
+#endif /* EFX_NIC_H */
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 22b0e89..957e534 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -15,7 +15,7 @@
 #include "efx.h"
 #include "mdio_10g.h"
 #include "phy.h"
-#include "falcon.h"
+#include "nic.h"
 
 #define QT202X_REQUIRED_DEVS (MDIO_DEVS_PCS |		\
 			      MDIO_DEVS_PMAPMD |	\
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 8fffd37..03eace3 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -17,7 +17,7 @@
 #include <net/checksum.h>
 #include "net_driver.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "selftest.h"
 #include "workarounds.h"
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 16258d8..1635f57 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -21,7 +21,7 @@
 #include <asm/io.h>
 #include "net_driver.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "selftest.h"
 #include "workarounds.h"
 #include "spi.h"
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 8de97a9..ff97133 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -12,7 +12,7 @@
 #include <linux/seq_file.h>
 #include "efx.h"
 #include "mdio_10g.h"
-#include "falcon.h"
+#include "nic.h"
 #include "phy.h"
 #include "regs.h"
 #include "workarounds.h"
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 2531d02..389ede4 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -16,7 +16,7 @@
 #include <linux/highmem.h>
 #include "net_driver.h"
 #include "efx.h"
-#include "falcon.h"
+#include "nic.h"
 #include "workarounds.h"
 
 /*
-- 
1.6.5.3



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

