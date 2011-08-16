From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 16 Aug 2011 13:26:59 +1000
Message-ID: <20110816132659.7719837bd136aa520c5814ac@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/net/ethernet/sun/sungem_phy.c:36:24: fatal error: sungem_phy.h: No such file or directory

Caused by commit 2bb698412d8a ("net: Move sungem_phy.h under
include/linux").

I applied this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 16 Aug 2011 13:22:24 +1000
Subject: [PATCH] sungem: sungem_phy.h moved

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/sun/sungem_phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem_phy.c b/drivers/net/ethernet/sun/sungem_phy.c
index d16880d..db99c22 100644
--- a/drivers/net/ethernet/sun/sungem_phy.c
+++ b/drivers/net/ethernet/sun/sungem_phy.c
@@ -33,7 +33,7 @@
 #include <asm/prom.h>
 #endif
 
-#include "sungem_phy.h"
+#include <linux/sungem_phy.h>
 
 /* Link modes of the BCM5400 PHY */
 static const int phy_BCM5400_link_table[8][3] = {
-- 
1.7.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
