From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/6] [BNX2]: Fix register test on 5709.
Date: Wed, 30 Apr 2008 15:51:38 -0700
Message-ID: <1209595898.7941.62.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, andy@greyhouse.net
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3315 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759558AbYD3VrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 17:47:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Fix register test on 5709.

The register BNX2_CTX_STATUS (0x1004) should be skipped on 5709 as it
contains reserved bits.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9c6f21f..b5560a9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4914,7 +4914,7 @@ bnx2_test_registers(struct bnx2 *bp)
 		{ 0x0c08, BNX2_FL_NOT_5709,  0x0f0ff073, 0x00000000 },
 
 		{ 0x1000, 0, 0x00000000, 0x00000001 },
-		{ 0x1004, 0, 0x00000000, 0x000f0001 },
+		{ 0x1004, BNX2_FL_NOT_5709, 0x00000000, 0x000f0001 },
 
 		{ 0x1408, 0, 0x01c00800, 0x00000000 },
 		{ 0x149c, 0, 0x8000ffff, 0x00000000 },
-- 
1.5.5.GIT



