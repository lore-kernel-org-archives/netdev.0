From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: [PATCH 1/2] net: ethernet: davinci_emac: Remove unnecessary #include
Date: Fri, 20 Jul 2012 18:12:40 -0700
Message-ID: <1342833161-3314-1-git-send-email-mgreer@animalcreek.com>
Cc: linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	"Mark A. Greer" <mgreer@animalcreek.com>,
	Sekhar Nori <nsekhar@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mark A. Greer" <mgreer@animalcreek.com>

The '#include <mach/mux.h>' line in davinci_emac.c
causes a compile error because that header file
isn't found.  It turns out that the #include isn't
needed because the driver isn't (and shoudn't be)
touching the mux anyway, so remove it.

CC: Sekhar Nori <nsekhar@ti.com>
Signed-off-by: Mark A. Greer <mgreer@animalcreek.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index b298ab0..1a9c43f 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -63,8 +63,6 @@
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
 
-#include <mach/mux.h>
-
 #include <asm/irq.h>
 #include <asm/page.h>
 
-- 
1.7.11.2

