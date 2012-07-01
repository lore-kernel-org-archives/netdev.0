From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 03/11] vxge: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:52 +0300
Message-ID: <1341148740-7375-4-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jon Mason" <jdmason@kudzu.us>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4176 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932314Ab2GANUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:41 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
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
