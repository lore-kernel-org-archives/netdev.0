From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 4/5] net: hp100: constify eisa_device_id
Date: Sat, 19 Aug 2017 12:23:14 +0530
Message-ID: <1503125594-15246-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, perex@perex.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eisa_device_id are not supposed to change at runtime. All functions
working with eisa_device_id provided by <linux/eisa.h> work with
const eisa_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/hp/hp100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index c6164a9..c8c7ad2 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -194,7 +194,7 @@ static const char *hp100_isa_tbl[] = {
 };
 #endif
 
-static struct eisa_device_id hp100_eisa_tbl[] = {
+static const struct eisa_device_id hp100_eisa_tbl[] = {
 	{ "HWPF180" }, /* HP J2577 rev A */
 	{ "HWP1920" }, /* HP 27248B */
 	{ "HWP1940" }, /* HP J2577 */
-- 
2.7.4
