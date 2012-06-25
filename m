From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 03/14] vxge: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 14:45:34 +0300
Message-ID: <1340624745-8650-4-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jon Mason" <jdmason@kudzu.us>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4197 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095Ab2FYLrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:47:52 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 2578eb1..2fd1edb 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3687,7 +3687,8 @@ static int __devinit vxge_config_vpaths(
 			return 0;
 
 		if (!driver_config->g_no_cpus)
-			driver_config->g_no_cpus = num_online_cpus();
+			driver_config->g_no_cpus =
+				netif_get_num_default_rss_queues();
 
 		driver_config->vpath_per_dev = driver_config->g_no_cpus >> 1;
 		if (!driver_config->vpath_per_dev)
-- 
1.7.9.rc2
