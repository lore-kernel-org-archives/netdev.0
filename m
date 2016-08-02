From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0781/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:44 +0800
Message-ID: <20160802114544.1811-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, lars@metafoo.de, johannes.berg@intel.com
To: j@w1.fi, kvalo@codeaurora.org, luciano.coelho@intel.com,
	linuxwifi@intel.com, m.chehab@samsung.com, pawel@osciak.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:22889 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934749AbcHBM0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:26:41 -0400
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
 drivers/net/wireless/intersil/hostap/hostap_plx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_plx.c b/drivers/net/wireless/intersil/hostap/hostap_plx.c
index 4901a99..cbdd2c7 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_plx.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_plx.c
@@ -34,7 +34,7 @@ MODULE_LICENSE("GPL");
 
 
 static int ignore_cis;
-module_param(ignore_cis, int, 0444);
+module_param(ignore_cis, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ignore_cis, "Do not verify manfid information in CIS");
 
 
-- 
2.9.2
