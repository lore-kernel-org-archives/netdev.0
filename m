From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4.10-rc3 08/13] net: emac: fix build errors when linux/phy*.h
 is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:19:04 +0000
Message-ID: <E1cYdxI-0000Wk-5w@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>
To: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170131191704.GA8281@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

drivers/net/ethernet/qualcomm/emac/emac-sgmii.c:58:12: error: dereferencing pointer to incomplete type 'struct phy_device'

Add linux/phy.h to emac-sgmii.c

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index bf722a9bb09d..5e31fb7e4ab8 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -16,6 +16,7 @@
 #include <linux/iopoll.h>
 #include <linux/acpi.h>
 #include <linux/of_device.h>
+#include <linux/phy.h>
 #include "emac.h"
 #include "emac-mac.h"
 #include "emac-sgmii.h"
-- 
2.7.4
