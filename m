From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 20/32] sfc: Rename Falcon-architecture register
 definitions
Date: Thu, 22 Aug 2013 13:55:42 +0100
Message-ID: <1377176142.1703.25.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56075 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3HVMzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:55:45 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EF10 architecture has a very different register layout from
previous controllers, so we'll use separate files for the two sets of
register definitions.  Use 'farch' as an abbreviation for
Falcon-architecture.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c                 | 2 +-
 drivers/net/ethernet/sfc/{regs.h => farch_regs.h} | 6 +++---
 drivers/net/ethernet/sfc/filter.c                 | 2 +-
 drivers/net/ethernet/sfc/mcdi.c                   | 2 +-
 drivers/net/ethernet/sfc/nic.c                    | 2 +-
 drivers/net/ethernet/sfc/ptp.c                    | 2 +-
 drivers/net/ethernet/sfc/siena.c                  | 2 +-
 drivers/net/ethernet/sfc/siena_sriov.c            | 2 +-
 8 files changed, 10 insertions(+), 10 deletions(-)
 rename drivers/net/ethernet/sfc/{regs.h => farch_regs.h} (99%)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 395d89d..f87710e 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -21,7 +21,7 @@
 #include "efx.h"
 #include "spi.h"
 #include "nic.h"
-#include "regs.h"
+#include "farch_regs.h"
 #include "io.h"
 #include "phy.h"
 #include "workarounds.h"
diff --git a/drivers/net/ethernet/sfc/regs.h b/drivers/net/ethernet/sfc/farch_regs.h
similarity index 99%
rename from drivers/net/ethernet/sfc/regs.h
rename to drivers/net/ethernet/sfc/farch_regs.h
index 27ad348d..00ef17a 100644
--- a/drivers/net/ethernet/sfc/regs.h
+++ b/drivers/net/ethernet/sfc/farch_regs.h
@@ -8,8 +8,8 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
-#ifndef EFX_REGS_H
-#define EFX_REGS_H
+#ifndef EFX_FARCH_REGS_H
+#define EFX_FARCH_REGS_H
 
 /*
  * Falcon hardware architecture definitions have a name prefix following
@@ -2925,4 +2925,4 @@
 #define FSF_AZ_DRV_GEN_EV_MAGIC_LBN 0
 #define FSF_AZ_DRV_GEN_EV_MAGIC_WIDTH 32
 
-#endif /* EFX_REGS_H */
+#endif /* EFX_FARCH_REGS_H */
diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 30d7442..fb01fdb 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -13,7 +13,7 @@
 #include "filter.h"
 #include "io.h"
 #include "nic.h"
-#include "regs.h"
+#include "farch_regs.h"
 
 /* "Fudge factors" - difference between programmed value and actual depth.
  * Due to pipelined implementation we need to program H/W with a value that
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index d7d3a8a..dffadb2 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -11,7 +11,7 @@
 #include "net_driver.h"
 #include "nic.h"
 #include "io.h"
-#include "regs.h"
+#include "farch_regs.h"
 #include "mcdi_pcol.h"
 #include "phy.h"
 
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 372891c..f758333 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -19,7 +19,7 @@
 #include "bitfield.h"
 #include "efx.h"
 #include "nic.h"
-#include "regs.h"
+#include "farch_regs.h"
 #include "io.h"
 #include "workarounds.h"
 
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 56a8b88..59e09e1 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -46,7 +46,7 @@
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 #include "io.h"
-#include "regs.h"
+#include "farch_regs.h"
 #include "nic.h"
 
 /* Maximum number of events expected to make up a PTP event */
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index f0ae262..d0eeb03 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -19,7 +19,7 @@
 #include "efx.h"
 #include "nic.h"
 #include "spi.h"
-#include "regs.h"
+#include "farch_regs.h"
 #include "io.h"
 #include "phy.h"
 #include "workarounds.h"
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 6258e7f..4d214bc 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -15,7 +15,7 @@
 #include "mcdi.h"
 #include "filter.h"
 #include "mcdi_pcol.h"
-#include "regs.h"
+#include "farch_regs.h"
 #include "vfdi.h"
 
 /* Number of longs required to track all the VIs in a VF */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
