From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: use SET_RUNTIME_PM_OPS()
Date: Thu, 22 Jan 2015 01:18:44 +0300
Message-ID: <1921430.9kt2FLVU1I@wasted.cogentembedded.com>
References: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, mikhail.ulyanov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikhail Ulyanov <mikhail.ulyanov@cogentembedded.com>

Use SET_RUNTIME_PM_OPS() macro to initialize the runtime PM method pointers in
the 'struct dev_pm_ops'.

Signed-off-by: Mikhail Ulyanov <mikhail.ulyanov@cogentembedded.com>
[Sergei: renamed, added the changelog.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2960,8 +2960,7 @@ static int sh_eth_runtime_nop(struct dev
 }
 
 static const struct dev_pm_ops sh_eth_dev_pm_ops = {
-	.runtime_suspend = sh_eth_runtime_nop,
-	.runtime_resume = sh_eth_runtime_nop,
+	SET_RUNTIME_PM_OPS(sh_eth_runtime_nop, sh_eth_runtime_nop, NULL)
 };
 #define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
 #else

