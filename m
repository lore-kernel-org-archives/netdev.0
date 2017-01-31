From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4.10-rc3 03/13] net: macb: fix build errors when linux/phy*.h
 is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:18:38 +0000
Message-ID: <E1cYdws-0000W9-GV@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>
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

drivers/net/ethernet/cadence/macb.h:862:33: sparse: expected ; at end of declaration
drivers/net/ethernet/cadence/macb.h:862:33: sparse: Expected } at end of struct-union-enum-specifier
drivers/net/ethernet/cadence/macb.h:862:33: sparse: got phy_interface
drivers/net/ethernet/cadence/macb.h:877:1: sparse: Expected ; at the end of type declaration
drivers/net/ethernet/cadence/macb.h:877:1: sparse: got }
In file included from drivers/net/ethernet/cadence/macb_pci.c:29:0:
drivers/net/ethernet/cadence/macb.h:862:2: error: unknown type name 'phy_interface_t'
     phy_interface_t  phy_interface;
     ^~~~~~~~~~~~~~~

Add linux/phy.h to macb.h

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/cadence/macb.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d67adad67be1..383da8cf5f6d 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -10,6 +10,8 @@
 #ifndef _MACB_H
 #define _MACB_H
 
+#include <linux/phy.h>
+
 #define MACB_GREGS_NBR 16
 #define MACB_GREGS_VERSION 2
 #define MACB_MAX_QUEUES 8
-- 
2.7.4
