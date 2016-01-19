From: Lucas Tanure <tanure@linux.com>
Subject: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Tue, 19 Jan 2016 21:27:54 -0200
Message-ID: <1453246074-1054-1-git-send-email-tanure@linux.com>
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shradha Shah <sshah@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use eth_zero_addr to assign the zero address to the given address array
instead of memset when second argument is address of zero.

Signed-off-by: Lucas Tanure <tanure@linux.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 3c17f27..10f60db 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -527,7 +527,7 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
 	return 0;
 
 fail:
-	memset(vf->mac, 0, ETH_ALEN);
+	eth_zero_addr(vf->mac);
 	return rc;
 }
 
-- 
2.7.0
