From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 09/17] sfc: Remove unnecessary inclusion of
 various private header files
Date: Thu, 02 Dec 2010 23:47:17 +0000
Message-ID: <1291333637.3259.32.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13046 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295Ab0LBXrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:20 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |    1 -
 drivers/net/sfc/ethtool.c       |    1 -
 drivers/net/sfc/falcon.c        |    1 -
 drivers/net/sfc/falcon_boards.c |    2 --
 drivers/net/sfc/falcon_xmac.c   |    1 -
 drivers/net/sfc/mcdi_phy.c      |    1 -
 drivers/net/sfc/mdio_10g.c      |    1 -
 drivers/net/sfc/tenxpress.c     |    2 --
 8 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 05df20e..b4580c4 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -23,7 +23,6 @@
 #include <linux/gfp.h>
 #include "net_driver.h"
 #include "efx.h"
-#include "mdio_10g.h"
 #include "nic.h"
 
 #include "mcdi.h"
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 00fb674..aae756b 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -17,7 +17,6 @@
 #include "efx.h"
 #include "filter.h"
 #include "nic.h"
-#include "mdio_10g.h"
 
 struct ethtool_string {
 	char name[ETH_GSTRING_LEN];
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b2c3381..fe15084 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -24,7 +24,6 @@
 #include "nic.h"
 #include "regs.h"
 #include "io.h"
-#include "mdio_10g.h"
 #include "phy.h"
 #include "workarounds.h"
 
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 6c20d45..a6fc5ce 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -13,8 +13,6 @@
 #include "phy.h"
 #include "efx.h"
 #include "nic.h"
-#include "regs.h"
-#include "io.h"
 #include "workarounds.h"
 
 /* Macros for unpacking the board revision */
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index b31f595..e293e25 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -16,7 +16,6 @@
 #include "io.h"
 #include "mac.h"
 #include "mdio_10g.h"
-#include "phy.h"
 #include "workarounds.h"
 
 /**************************************************************************
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index c992742..0e97eed 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -16,7 +16,6 @@
 #include "phy.h"
 #include "mcdi.h"
 #include "mcdi_pcol.h"
-#include "mdio_10g.h"
 #include "nic.h"
 #include "selftest.h"
 
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 98d9460..56b0266 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -15,7 +15,6 @@
 #include "net_driver.h"
 #include "mdio_10g.h"
 #include "workarounds.h"
-#include "nic.h"
 
 unsigned efx_mdio_id_oui(u32 id)
 {
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 1bc6c48..f102912 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -15,9 +15,7 @@
 #include "mdio_10g.h"
 #include "nic.h"
 #include "phy.h"
-#include "regs.h"
 #include "workarounds.h"
-#include "selftest.h"
 
 /* We expect these MMDs to be in the package. */
 #define TENXPRESS_REQUIRED_DEVS (MDIO_DEVS_PMAPMD	| \
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

