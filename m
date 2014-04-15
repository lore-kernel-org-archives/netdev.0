From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] cxgb4: use the correct max size for firmware flash
Date: Tue, 15 Apr 2014 13:50:48 -0500
Message-ID: <20140415185047.17386.71861.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:56041 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbaDOSus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 14:50:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The wrong max fw size was being used and causing false
"too big" errors running ethtool -f.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 9d0a8cd..9aaf41c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -689,7 +689,7 @@ enum {
 	SF_RD_ID        = 0x9f,       /* read ID */
 	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
 
-	FW_MAX_SIZE = 4 * 512 * 1024,
+	FW_MAX_SIZE = 16 * SF_SEC_SIZE,
 };
 
 /**
