From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 4/8] net/mlx4_core: Remove unused *_str functions from the resource tracker
Date: Tue, 15 May 2012 10:24:46 +0300
Message-ID: <1337066690-2248-5-git-send-email-ogerlitz@mellanox.com>
References: <1337066690-2248-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:57123 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756848Ab2EOHZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 03:25:01 -0400
In-Reply-To: <1337066690-2248-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Removed unsued *_str helper functions from resource_tracker.c

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   30 --------------------
 1 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 215c165..2cb3a10 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -89,17 +89,6 @@ enum res_qp_states {
 	RES_QP_HW
 };
 
-static inline const char *qp_states_str(enum res_qp_states state)
-{
-	switch (state) {
-	case RES_QP_BUSY: return "RES_QP_BUSY";
-	case RES_QP_RESERVED: return "RES_QP_RESERVED";
-	case RES_QP_MAPPED: return "RES_QP_MAPPED";
-	case RES_QP_HW: return "RES_QP_HW";
-	default: return "Unknown";
-	}
-}
-
 struct res_qp {
 	struct res_common	com;
 	struct res_mtt	       *mtt;
@@ -173,16 +162,6 @@ enum res_srq_states {
 	RES_SRQ_HW,
 };
 
-static inline const char *srq_states_str(enum res_srq_states state)
-{
-	switch (state) {
-	case RES_SRQ_BUSY: return "RES_SRQ_BUSY";
-	case RES_SRQ_ALLOCATED: return "RES_SRQ_ALLOCATED";
-	case RES_SRQ_HW: return "RES_SRQ_HW";
-	default: return "Unknown";
-	}
-}
-
 struct res_srq {
 	struct res_common	com;
 	struct res_mtt	       *mtt;
@@ -195,15 +174,6 @@ enum res_counter_states {
 	RES_COUNTER_ALLOCATED,
 };
 
-static inline const char *counter_states_str(enum res_counter_states state)
-{
-	switch (state) {
-	case RES_COUNTER_BUSY: return "RES_COUNTER_BUSY";
-	case RES_COUNTER_ALLOCATED: return "RES_COUNTER_ALLOCATED";
-	default: return "Unknown";
-	}
-}
-
 struct res_counter {
 	struct res_common	com;
 	int			port;
-- 
1.7.1
