From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 01/21] drivers: remove unnecessary prom.h includes
Date: Thu, 26 Sep 2013 13:50:36 -0500
Message-ID: <1380221456-11192-2-git-send-email-robherring2@gmail.com>
References: <1380221456-11192-1-git-send-email-robherring2@gmail.com>
Cc: Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1380221456-11192-1-git-send-email-robherring2@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Remove unnecessary prom.h includes in preparation to remove implicit
includes of prom.h.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/can/grcan.c                       | 3 ---
 drivers/net/can/sja1000/sja1000_of_platform.c | 1 -
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 6aa737a..ab506d6 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -34,10 +34,7 @@
 #include <linux/io.h>
 #include <linux/can/dev.h>
 #include <linux/spinlock.h>
-
 #include <linux/of_platform.h>
-#include <asm/prom.h>
-
 #include <linux/of_irq.h>
 
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 31ad339..047accd 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -44,7 +44,6 @@
 #include <linux/of_platform.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
-#include <asm/prom.h>
 
 #include "sja1000.h"
 
-- 
1.8.1.2

