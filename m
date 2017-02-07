From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 02/12] net: cgroups: fix build errors when linux/phy*.h is removed from net/dsa.h
Date: Tue,  7 Feb 2017 15:02:55 -0800
Message-ID: <20170207230305.18222-3-f.fainelli@gmail.com>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
Cc: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jiri Slaby <jirislaby@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
        Nick Kossifidis <mickflemm@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Raghu Vatsavayi <raghu.vatsavay
To: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        target-devel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170207230305.18222-1-f.fainelli@gmail.com>
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

From: Russell King <rmk+kernel@armlinux.org.uk>

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
2.9.3
