From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] SMC91x: delete unused local variable "lp"
Date: Wed, 29 Oct 2008 09:56:06 -0400
Message-ID: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
Cc: linux-kernel@vger.kernel.org
To: nico@cam.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754353AbYJ2N4W@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/smc91x.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index c70870e..6f9895d 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2060,7 +2060,6 @@ static int smc_request_attrib(struct platform_device *pdev,
 			      struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
-	struct smc_local *lp = netdev_priv(ndev);
 
 	if (!res)
 		return 0;
@@ -2075,7 +2074,6 @@ static void smc_release_attrib(struct platform_device *pdev,
 			       struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
-	struct smc_local *lp = netdev_priv(ndev);
 
 	if (res)
 		release_mem_region(res->start, ATTRIB_SIZE);
-- 
1.6.0.2
