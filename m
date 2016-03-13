From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 09/12] cxgb4: move VLAN_NONE macro definition
Date: Sun, 13 Mar 2016 19:49:31 +0530
Message-ID: <2460510ab4ada7525eceb2bc09632adc03a8356d.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move VLAN_NONE macro definition from l2t.c
to l2t.h

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/l2t.c | 2 --
 drivers/net/ethernet/chelsio/cxgb4/l2t.h | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 5b0f3ef..60a2603 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -48,8 +48,6 @@
 #include "t4_regs.h"
 #include "t4_values.h"
 
-#define VLAN_NONE 0xfff
-
 /* identifies sync vs async L2T_WRITE_REQs */
 #define SYNC_WR_S    12
 #define SYNC_WR_V(x) ((x) << SYNC_WR_S)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.h b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
index 4e2d47a..79665bd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
@@ -39,6 +39,8 @@
 #include <linux/if_ether.h>
 #include <linux/atomic.h>
 
+#define VLAN_NONE 0xfff
+
 enum { L2T_SIZE = 4096 };     /* # of L2T entries */
 
 enum {
-- 
2.0.2
