From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] ehea: Drop owner assignment from platform_driver
Date: Fri, 19 Feb 2016 16:52:19 +0530
Message-ID: <20160219112219.GA2366@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_driver does not need to set an owner, it will be populated by
the driver core.

Generated-by: scripts/coccinelle/api/platform_no_drv_owner.cocci

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 2a0dc12..d4b022f 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -127,7 +127,6 @@ static const struct of_device_id ehea_device_table[] = {
 static struct platform_driver ehea_driver = {
 	.driver = {
 		.name = "ehea",
-		.owner = THIS_MODULE,
 		.of_match_table = ehea_device_table,
 	},
 	.probe = ehea_probe_adapter,
-- 
1.9.1
