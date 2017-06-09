From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: aquantia: atlantic: remove declaration of hw_atl_utils_hw_set_power
Date: Fri,  9 Jun 2017 23:50:57 +0200
Message-ID: <1497045057-18299-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: Alexander.Loktionov@aquantia.com, Pavel.Belous@aquantia.com,
        davem@davemloft.net, Dmitry.Bezrukov@aquantia.com,
        vomlehn@texas.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is not defined, so no need to declare it.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
index b8e3d88..a66aee5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
@@ -193,9 +193,6 @@ int hw_atl_utils_hw_get_regs(struct aq_hw_s *self,
 			     struct aq_hw_caps_s *aq_hw_caps,
 			     u32 *regs_buff);
 
-int hw_atl_utils_hw_get_settings(struct aq_hw_s *self,
-				 struct ethtool_cmd *cmd);
-
 int hw_atl_utils_hw_set_power(struct aq_hw_s *self,
 			      unsigned int power_state);
 
-- 
1.7.4.4
