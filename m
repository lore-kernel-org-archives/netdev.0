From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH] net: gianfar_ptp: Fix module autoload for OF platform driver
Date: Fri, 18 Sep 2015 21:52:44 +0200
Message-ID: <20150918195244.GA3221@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This platform driver has a OF device ID table but the OF module
alias information is not created so module autoloading won't work.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---

Corrected the subject line as requested by Richard.
https://lkml.org/lkml/2015/9/18/717

Thanks for the review,
Luis

 drivers/net/ethernet/freescale/gianfar_ptp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 8e3cd77..664d0c2 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -557,6 +557,7 @@ static const struct of_device_id match_table[] = {
 	{ .compatible = "fsl,etsec-ptp" },
 	{},
 };
+MODULE_DEVICE_TABLE(of, match_table);
 
 static struct platform_driver gianfar_ptp_driver = {
 	.driver = {
-- 
2.4.6
