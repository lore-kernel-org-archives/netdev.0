From: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH] cpts: add missing <linux/if_vlan.h>
Date: Sun,  6 Apr 2014 14:55:31 +0300
Message-ID: <1396785331-26875-1-git-send-email-slyich@gmail.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Trofimovich <slyfox@gentoo.org>

gcc complains as:
    drivers/net/ethernet/ti/cpts.c: In function 'cpts_match':
    drivers/net/ethernet/ti/cpts.c:266:12: error: 'ETH_HLEN' undeclared (first use in this function)
    drivers/net/ethernet/ti/cpts.c:266:12: note: each undeclared identifier is reported only once for each function it appears in
    drivers/net/ethernet/ti/cpts.c:276:23: error: 'VLAN_HLEN' undeclared (first use in this function)

Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/ti/cpts.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index a3bbf59..c413e79 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -19,6 +19,7 @@
  */
 #include <linux/err.h>
 #include <linux/if.h>
+#include <linux/if_vlan.h>
 #include <linux/hrtimer.h>
 #include <linux/module.h>
 #include <linux/net_tstamp.h>
-- 
1.9.0
