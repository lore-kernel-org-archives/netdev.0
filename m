From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4.10-rc3 02/13] net: cgroups: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:18:33 +0000
Message-ID: <E1cYdwn-0000W0-Cz@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
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

net/core/netprio_cgroup.c:303:16: error: expected declaration specifiers or '...' before string constant
    MODULE_LICENSE("GPL v2");
                   ^~~~~~~~

Add linux/module.h to fix this.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 net/core/netprio_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 2ec86fc552df..756637dc7a57 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -13,6 +13,7 @@
 
 #include <linux/slab.h>
 #include <linux/types.h>
+#include <linux/module.h>
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
-- 
2.7.4
