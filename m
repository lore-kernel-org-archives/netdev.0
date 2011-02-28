From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 2/7] bnx2x: Fix nvram test for single port
 devices.
Date: Mon, 28 Feb 2011 15:37:13 +0200
Message-ID: <1298900233.28024.120.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1936 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138Ab1B1NjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:39:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index b3da295..5b0fe7a 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1782,9 +1782,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x100, 0x350 }, /* manuf_info */
 		{ 0x450,  0xf0 }, /* feature_info */
 		{ 0x640,  0x64 }, /* upgrade_key_info */
-		{ 0x6a4,  0x64 },
 		{ 0x708,  0x70 }, /* manuf_key_info */
-		{ 0x778,  0x70 },
 		{     0,     0 }
 	};
 	__be32 buf[0x350 / 4];
-- 
1.7.2.2




