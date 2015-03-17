From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 07/16 linux-next] netdev: octeon_mgmt: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:38 +0100
Message-ID: <1426617469-781-8-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617469-781-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index d36599f..7bf9c02 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1557,7 +1557,7 @@ static int octeon_mgmt_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id octeon_mgmt_match[] = {
+static const struct of_device_id octeon_mgmt_match[] = {
 	{
 		.compatible = "cavium,octeon-5750-mix",
 	},
-- 
2.1.0
