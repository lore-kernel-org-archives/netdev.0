From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Fix ethtool statistics for 82xx adapter
Date: Fri,  8 Mar 2013 14:53:51 -0500
Message-ID: <1362772433-12045-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:4999 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754627Ab3CHURA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 15:17:00 -0500
In-Reply-To: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Fix miscalculation of statistics length

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index ba1502a..f687a63 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -149,7 +149,8 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 
 static inline int qlcnic_82xx_statistics(void)
 {
-	return QLCNIC_STATS_LEN + ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
+	return ARRAY_SIZE(qlcnic_device_gstrings_stats) +
+	       ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
 }
 
 static inline int qlcnic_83xx_statistics(void)
-- 
1.5.6
