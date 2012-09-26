From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 1/7] cxgb4: Fix incorrect values for MEMWIN*_APERTURE and MEMWIN*_BASE
Date: Wed, 26 Sep 2012 18:09:36 +0530
Message-ID: <1348663182-20190-2-git-send-email-vipul@chelsio.com>
References: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com, felix@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17360 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab2IZMnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:43:10 -0400
In-Reply-To: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ec2dafe..f3fe236 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -67,12 +67,12 @@ enum {
 };
 
 enum {
-	MEMWIN0_APERTURE = 65536,
-	MEMWIN0_BASE     = 0x30000,
+	MEMWIN0_APERTURE = 2048,
+	MEMWIN0_BASE     = 0x1b800,
 	MEMWIN1_APERTURE = 32768,
 	MEMWIN1_BASE     = 0x28000,
-	MEMWIN2_APERTURE = 2048,
-	MEMWIN2_BASE     = 0x1b800,
+	MEMWIN2_APERTURE = 65536,
+	MEMWIN2_BASE     = 0x30000,
 };
 
 enum dev_master {
-- 
1.7.1
