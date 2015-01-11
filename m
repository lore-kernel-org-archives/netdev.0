From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v1] net: bnx2x: avoid macro redefinition
Date: Sun, 11 Jan 2015 11:42:37 -0800
Message-ID: <1421005357-25708-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot@googlers.com>
To: Ariel Elior <ariel.elior@qlogic.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 792ba72..756053c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1138,12 +1138,8 @@ struct bnx2x_port {
 	u32			link_config[LINK_CONFIG_SIZE];
 
 	u32			supported[LINK_CONFIG_SIZE];
-/* link settings - missing defines */
-#define SUPPORTED_2500baseX_Full	(1 << 15)
 
 	u32			advertising[LINK_CONFIG_SIZE];
-/* link settings - missing defines */
-#define ADVERTISED_2500baseX_Full	(1 << 15)
 
 	u32			phy_addr;
 
-- 
2.2.0.rc0.207.ga3a616c
