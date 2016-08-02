From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0717/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:31 +0800
Message-ID: <20160802113931.29863-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org, mugunthanvnm@ti.com, a@unstable.cc,
	fw@strlen.de, davem@davemloft.net, chuansheng.liu@intel.com,
	baolex.ni@intel.com, Baohua.Song@csr.com
To: leedom@chelsio.com, rric@kernel.org,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/dec/tulip/uli526x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index e750b5d..a6cd07a 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -1789,7 +1789,7 @@ MODULE_AUTHOR("Peer Chen, peer.chen@uli.com.tw");
 MODULE_DESCRIPTION("ULi M5261/M5263 fast ethernet driver");
 MODULE_LICENSE("GPL");
 
-module_param(debug, int, 0644);
+module_param(debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param(mode, int, 0);
 module_param(cr6set, int, 0);
 MODULE_PARM_DESC(debug, "ULi M5261/M5263 enable debugging (0-1)");
-- 
2.9.2

