From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 26/34]bnx2x: Read chip ID
Date: Wed, 14 Jan 2009 18:44:04 +0200
Message-ID: <1231951444.11301.147.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764125AbZANQpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f97c4e0..678bc5d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7010,7 +7010,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	id |= ((val & 0xf) << 12);
 	val = REG_RD(bp, MISC_REG_CHIP_METAL);
 	id |= ((val & 0xff) << 4);
-	REG_RD(bp, MISC_REG_BOND_ID);
+	val = REG_RD(bp, MISC_REG_BOND_ID);
 	id |= (val & 0xf);
 	bp->common.chip_id = id;
 	bp->link_params.chip_id = bp->common.chip_id;
-- 
1.5.4.3




