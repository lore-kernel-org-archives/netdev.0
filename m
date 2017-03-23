From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 2/2] net: dwc-xlgmac: use dual license
Date: Thu, 23 Mar 2017 12:03:46 +0800
Message-ID: <373634ab2a40ef2f3d1beead97d17e8d3b6ac2d3.1490239652.git.jiedeng@synopsys.com>
References: <eed57e46080bcf76715eb19b3d58efcace8dc324.1490239652.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <eed57e46080bcf76715eb19b3d58efcace8dc324.1490239652.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver "dwc-xlgmac" is dual-licensed.
Declare the dual license with MODULE_LICENSE().

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
 drivers/net/ethernet/synopsys/dwc-xlgmac-common.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
index cb11928..07def2b 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
@@ -21,9 +21,10 @@
 #include "dwc-xlgmac.h"
 #include "dwc-xlgmac-reg.h"
 
+MODULE_LICENSE("Dual BSD/GPL");
+
 static int debug = -1;
 module_param(debug, int, 0644);
-MODULE_LICENSE("GPL");
 MODULE_PARM_DESC(debug, "DWC ethernet debug level (0=none,...,16=all)");
 static const u32 default_msg_level = (NETIF_MSG_LINK | NETIF_MSG_IFDOWN |
 				      NETIF_MSG_IFUP);
-- 
1.9.1
