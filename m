From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 3/3] net/mlx4_en: Advertize DCB_CAP_DCBX_HOST in getdcbx
Date: Sun,  7 Apr 2013 16:44:08 +0300
Message-ID: <1365342248-31901-4-git-send-email-ogerlitz@mellanox.com>
References: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sagig@mellanox.com,
	john.r.fastabend@intel.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:56915 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760668Ab3DGOMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 10:12:55 -0400
In-Reply-To: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When our getdcbx entry is called, DCB_CAP_DCBX_HOST should be advertized too.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 321553f..9199aed 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -186,7 +186,7 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 
 static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
 {
-	return DCB_CAP_DCBX_VER_IEEE;
+	return (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE);
 }
 
 static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
-- 
1.7.1
