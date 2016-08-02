From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0709/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:38:45 +0800
Message-ID: <20160802113845.29322-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, netdev@vger.kernel.org,
 fw@strlen.de, linux-kernel@vger.kernel.org, baolex.ni@intel.com,
 hdegoede@redhat.com, chuansheng.liu@intel.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: maxime.ripard@free-electrons.com, wens@csie.org, gospo@cumulusnetworks.com,
 computersforpeace@gmail.com, m.chehab@samsung.com, pawel@osciak.com,
 m.szyprowski@samsung.com, kyungmin.park@samsung.com,
 k.kozlowski@samsung.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index de2c4bf..c502059 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -39,7 +39,7 @@
 
 /* Transmit timeout, default 5 seconds. */
 static int watchdog = 5000;
-module_param(watchdog, int, 0400);
+module_param(watchdog, int, S_IRUSR);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
 /* EMAC register address locking.
-- 
2.9.2
