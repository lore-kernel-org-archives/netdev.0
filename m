From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0070/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 18:38:27 +0800
Message-ID: <20160802103827.18420-1-baolex.ni@intel.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: 3chas3@gmail.com, tj@kernel.org, lenb@kernel.org, x86@kernel.org,
	hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12528 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779AbcHBLTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 07:19:17 -0400
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
 drivers/atm/horizon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 527bbd5..0662aaa 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2857,7 +2857,7 @@ static void __init hrz_check_args (void) {
 MODULE_AUTHOR(maintainer_string);
 MODULE_DESCRIPTION(description_string);
 MODULE_LICENSE("GPL");
-module_param(debug, ushort, 0644);
+module_param(debug, ushort, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param(vpi_bits, ushort, 0);
 module_param(max_tx_size, int, 0);
 module_param(max_rx_size, int, 0);
-- 
2.9.2
