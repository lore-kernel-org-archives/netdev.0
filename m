From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0710/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:38:50 +0800
Message-ID: <20160802113850.29388-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, hdegoede@redhat.com,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, fw@strlen.de
To: rasesh.mody@qlogic.com, wens@csie.org, gospo@cumulusnetworks.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55833 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934103AbcHBMRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:17:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 771cc26..0d1f6e8 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -38,11 +38,11 @@ static DEFINE_MUTEX(bnad_fwimg_mutex);
  * Module params
  */
 static uint bnad_msix_disable;
-module_param(bnad_msix_disable, uint, 0444);
+module_param(bnad_msix_disable, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bnad_msix_disable, "Disable MSIX mode");
 
 static uint bnad_ioc_auto_recover = 1;
-module_param(bnad_ioc_auto_recover, uint, 0444);
+module_param(bnad_ioc_auto_recover, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable / Disable auto recovery");
 
 static uint bna_debugfs_enable = 1;
-- 
2.9.2
