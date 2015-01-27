From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 10/11] net/mlx4_core: Fix device capabilities dumping
Date: Tue, 27 Jan 2015 15:58:08 +0200
Message-ID: <1422367089-13419-11-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46324 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756154AbbA0N7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:04 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We are dumping device capabilities which are supported both by the
firmware and the driver. Align the array that holds the capability
strings with this practice.

Reported-by: Yuval Shaia <yuval.shaia@oracle.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 0c90d10..0ab81a9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -84,13 +84,10 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[ 1] = "UC transport",
 		[ 2] = "UD transport",
 		[ 3] = "XRC transport",
-		[ 4] = "reliable multicast",
-		[ 5] = "FCoIB support",
 		[ 6] = "SRQ support",
 		[ 7] = "IPoIB checksum offload",
 		[ 8] = "P_Key violation counter",
 		[ 9] = "Q_Key violation counter",
-		[10] = "VMM",
 		[12] = "Dual Port Different Protocol (DPDP) support",
 		[15] = "Big LSO headers",
 		[16] = "MW support",
@@ -99,12 +96,11 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[19] = "Raw multicast support",
 		[20] = "Address vector port checking support",
 		[21] = "UD multicast support",
-		[24] = "Demand paging support",
-		[25] = "Router support",
 		[30] = "IBoE support",
 		[32] = "Unicast loopback support",
 		[34] = "FCS header control",
-		[38] = "Wake On LAN support",
+		[37] = "Wake On LAN (port1) support",
+		[38] = "Wake On LAN (port2) support",
 		[40] = "UDP RSS support",
 		[41] = "Unicast VEP steering support",
 		[42] = "Multicast VEP steering support",
-- 
1.9.3
