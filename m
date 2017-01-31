From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4.10-rc3 09/13] iscsi: fix build errors when linux/phy*.h is
 removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:19:09 +0000
Message-ID: <E1cYdxN-0000Wr-AS@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
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

drivers/target/iscsi/iscsi_target_login.c:1135:7: error: implicit declaration of function 'try_module_get' [-Werror=implicit-function-declaration]

Add linux/module.h to iscsi_target_login.c.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/target/iscsi/iscsi_target_login.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/iscsi/iscsi_target_login.c
index 450f51deb2a2..eab274d17b5c 100644
--- a/drivers/target/iscsi/iscsi_target_login.c
+++ b/drivers/target/iscsi/iscsi_target_login.c
@@ -17,6 +17,7 @@
  ******************************************************************************/
 
 #include <crypto/hash.h>
+#include <linux/module.h>
 #include <linux/string.h>
 #include <linux/kthread.h>
 #include <linux/idr.h>
-- 
2.7.4
