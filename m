From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch] bnx2x: Change bnx2x_tests_str_arr to static
 char
Date: Tue, 26 Jun 2012 19:11:03 +0300
Message-ID: <1340727063-23870-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4508 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132Ab2FZNDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 09:03:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the definition of bnx2x_tests_str_arr from char to static
char. This correction will also eliminate the sparse warning created in commit
cf2c1df62e065bfc15e38daf2d3479a56b320f29.

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
index 1f8c156..bff3129 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1600,7 +1600,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	return 0;
 }
 
-char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
+static char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
 	"register_test (offline)    ",
 	"memory_test (offline)      ",
 	"int_loopback_test (offline)",
-- 
1.7.10
