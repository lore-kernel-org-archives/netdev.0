From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 2/5] net: 3c59x: constify eisa_device_id
Date: Sat, 19 Aug 2017 12:22:13 +0530
Message-ID: <1503125533-15130-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, klassert@mathematik.tu-chemnitz.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eisa_device_id are not supposed to change at runtime. All functions
working with eisa_device_id provided by <linux/eisa.h> work with
const eisa_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/3com/3c59x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 3b516eb..402d909 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -900,7 +900,7 @@ static const struct dev_pm_ops vortex_pm_ops = {
 #endif /* !CONFIG_PM */
 
 #ifdef CONFIG_EISA
-static struct eisa_device_id vortex_eisa_ids[] = {
+static const struct eisa_device_id vortex_eisa_ids[] = {
 	{ "TCM5920", CH_3C592 },
 	{ "TCM5970", CH_3C597 },
 	{ "" }
-- 
2.7.4
