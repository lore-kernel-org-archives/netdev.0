From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 08/16 linux-next] net: greth: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:39 +0100
Message-ID: <1426617469-781-9-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
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
 drivers/net/ethernet/aeroflex/greth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 2b8bfee..ae89de7 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1588,7 +1588,7 @@ static int greth_of_remove(struct platform_device *of_dev)
 	return 0;
 }
 
-static struct of_device_id greth_of_match[] = {
+static const struct of_device_id greth_of_match[] = {
 	{
 	 .name = "GAISLER_ETHMAC",
 	 },
-- 
2.1.0
