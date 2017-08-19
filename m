From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 1/5] net: 3c509: constify eisa_device_id
Date: Sat, 19 Aug 2017 12:21:43 +0530
Message-ID: <1503125503-15075-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1503125503-15075-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503125503-15075-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eisa_device_id are not supposed to change at runtime. All functions
working with eisa_device_id provided by <linux/eisa.h> work with
const eisa_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/3com/3c509.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 077d01d..b223769 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -474,7 +474,7 @@ static int pnp_registered;
 #endif /* CONFIG_PNP */
 
 #ifdef CONFIG_EISA
-static struct eisa_device_id el3_eisa_ids[] = {
+static const struct eisa_device_id el3_eisa_ids[] = {
 		{ "TCM5090" },
 		{ "TCM5091" },
 		{ "TCM5092" },
-- 
2.7.4
