From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4.10-rc3 04/13] net: lan78xx: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:18:43 +0000
Message-ID: <E1cYdwx-0000WG-L9@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
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

drivers/net/usb/lan78xx.c:394:33: sparse: expected ; at end of declaration
drivers/net/usb/lan78xx.c:394:33: sparse: Expected } at end of struct-union-enum-specifier
drivers/net/usb/lan78xx.c:394:33: sparse: got interface
drivers/net/usb/lan78xx.c:403:1: sparse: Expected ; at the end of type declaration
drivers/net/usb/lan78xx.c:403:1: sparse: got }

Add linux/phy.h to lan78xx.c

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/usb/lan78xx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 08f8703e4d54..9889a70ff4f6 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -35,6 +35,7 @@
 #include <linux/irq.h>
 #include <linux/irqchip/chained_irq.h>
 #include <linux/microchipphy.h>
+#include <linux/phy.h>
 #include "lan78xx.h"
 
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
-- 
2.7.4
