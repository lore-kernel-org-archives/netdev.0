From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 15/16 linux-next] net: via-rhine: constify of_device_id array
Date: Tue, 17 Mar 2015 19:40:27 +0100
Message-ID: <1426617628-937-6-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617628-937-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617628-937-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/via/via-rhine.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 8fb807e..de28504 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -288,7 +288,7 @@ MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
  * The .data field is currently only used to store quirks
  */
 static u32 vt8500_quirks = rqWOL | rqForceReset | rq6patterns;
-static struct of_device_id rhine_of_tbl[] = {
+static const struct of_device_id rhine_of_tbl[] = {
 	{ .compatible = "via,vt8500-rhine", .data = &vt8500_quirks },
 	{ }	/* terminate list */
 };
-- 
2.1.0
