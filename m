From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net-next] ravb: Add SET_RUNTIME_PM_OPS macro
Date: Mon, 30 May 2016 05:25:43 +0900
Message-ID: <1464553543-19091-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

Use SET_RUNTIME_PM_OPS macro instead of assigning a member of
dev_pm_ops directly.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

 drivers/net/ethernet/renesas/ravb_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 867caf6..da8da86 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -2111,8 +2111,7 @@ static int ravb_runtime_nop(struct device *dev)
 }
 
 static const struct dev_pm_ops ravb_dev_pm_ops = {
-	.runtime_suspend = ravb_runtime_nop,
-	.runtime_resume = ravb_runtime_nop,
+	SET_RUNTIME_PM_OPS(ravb_runtime_nop, ravb_runtime_nop, NULL)
 };
 
 #define RAVB_PM_OPS (&ravb_dev_pm_ops)
-- 
1.9.1
