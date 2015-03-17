From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 04/16 linux-next] net: ethoc: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:35 +0100
Message-ID: <1426617469-781-5-git-send-email-fabf@skynet.be>
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
 drivers/net/ethernet/ethoc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index f88cfaa..442410c 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1299,7 +1299,7 @@ static int ethoc_resume(struct platform_device *pdev)
 # define ethoc_resume  NULL
 #endif
 
-static struct of_device_id ethoc_match[] = {
+static const struct of_device_id ethoc_match[] = {
 	{ .compatible = "opencores,ethoc", },
 	{},
 };
-- 
2.1.0
