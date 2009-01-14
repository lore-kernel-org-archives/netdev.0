From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 16/34]bnx2x: MTU Filter
Date: Wed, 14 Jan 2009 18:43:30 +0200
Message-ID: <1231951410.11301.137.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760994AbZANQoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Too big packets could pass due to wrong filter size

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e7da72d..f4d3c23 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4556,7 +4556,7 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 	int i;
 
-	tstorm_client.mtu = bp->dev->mtu + ETH_OVREHEAD;
+	tstorm_client.mtu = bp->dev->mtu;
 	tstorm_client.statistics_counter_id = BP_CL_ID(bp);
 	tstorm_client.config_flags =
 				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
-- 
1.5.4.3




