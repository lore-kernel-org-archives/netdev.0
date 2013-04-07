From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 1/3] net/mlx4_core: Added proper description for two device capabilities
Date: Sun,  7 Apr 2013 16:44:06 +0300
Message-ID: <1365342248-31901-2-git-send-email-ogerlitz@mellanox.com>
References: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sagig@mellanox.com,
	john.r.fastabend@intel.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:47496 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933647Ab3DGNoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 09:44:19 -0400
In-Reply-To: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added readable description for the DPDP and port sensing device capabilities.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index f624557..8764397 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -91,7 +91,7 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[ 8] = "P_Key violation counter",
 		[ 9] = "Q_Key violation counter",
 		[10] = "VMM",
-		[12] = "DPDP",
+		[12] = "Dual Port Different Protocol (DPDP) support",
 		[15] = "Big LSO headers",
 		[16] = "MW support",
 		[17] = "APM support",
@@ -109,6 +109,7 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[41] = "Unicast VEP steering support",
 		[42] = "Multicast VEP steering support",
 		[48] = "Counters support",
+		[55] = "Port link type sensing support",
 		[59] = "Port management change event support",
 		[61] = "64 byte EQE support",
 		[62] = "64 byte CQE support",
-- 
1.7.1
