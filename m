From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4.10-rc3 07/13] net: mvneta: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:18:59 +0000
Message-ID: <E1cYdxD-0000Wd-1D@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
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

drivers/net/ethernet/marvell/mvneta.c:2694:26: error: storage size of 'status' isn't known
drivers/net/ethernet/marvell/mvneta.c:2695:26: error: storage size of 'changed' isn't known
drivers/net/ethernet/marvell/mvneta.c:2695:9: error: variable 'changed' has initializer but incomplete type
drivers/net/ethernet/marvell/mvneta.c:2709:2: error: implicit declaration of function 'fixed_phy_update_state' [-Werror=implicit-function-declaration]

Add linux/phy_fixed.h to mvneta.c

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvneta.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e05e22705cf7..eb0eb3e62ca0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -28,6 +28,7 @@
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/platform_device.h>
 #include <linux/skbuff.h>
 #include <net/hwbm.h>
-- 
2.7.4
