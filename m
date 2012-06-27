From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch] bnx2x: Define bnx2x_tests_str_arr as const
Date: Wed, 27 Jun 2012 14:52:56 +0300
Message-ID: <1340797976-13827-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1281 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab2F0Lx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 07:53:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the definition of bnx2x_tests_str_arr from static char to
static const char.

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this patch to net-next.

Thanks,
Merav

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index bff3129..81cadb6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1600,7 +1600,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	return 0;
 }
 
-static char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
+static const char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
 	"register_test (offline)    ",
 	"memory_test (offline)      ",
 	"int_loopback_test (offline)",
-- 
1.7.10
