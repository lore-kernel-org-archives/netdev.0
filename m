From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0749/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:33 +0800
Message-ID: <20160802114233.31994-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, pshelar@nicira.com,
	jbenc@redhat.com, daniel@iogearbox.net, hannes@stressinduktion.org,
	tom@herbertland.com, aduyck@mirantis.com
To: richardcochran@gmail.com, f.fainelli@gmail.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:7035 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934263AbcHBMUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:20:20 -0400
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
 drivers/net/phy/dp83640.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 7a240fc..a2a3e20 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -171,8 +171,8 @@ static ushort gpio_tab[GPIO_TABLE_SIZE] = {
 	1, 2, 3, 4, 8, 9, 10, 11
 };
 
-module_param(chosen_phy, int, 0444);
-module_param_array(gpio_tab, ushort, NULL, 0444);
+module_param(chosen_phy, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_array(gpio_tab, ushort, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 
 MODULE_PARM_DESC(chosen_phy, \
 	"The address of the PHY to use for the ancillary clock features");
-- 
2.9.2
