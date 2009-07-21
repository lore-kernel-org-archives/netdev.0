From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 9/10] bnx2x: Missing parenthesis might result with
 wrong casting
Date: Tue, 21 Jul 2009 18:47:51 +0300
Message-ID: <1248191271.18195.52.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4396 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754800AbZGUPsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:48:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 8b6e83d..8bd80fc 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -160,7 +160,7 @@ struct sw_rx_page {
 #define PAGES_PER_SGE			(1 << PAGES_PER_SGE_SHIFT)
 #define SGE_PAGE_SIZE			PAGE_SIZE
 #define SGE_PAGE_SHIFT			PAGE_SHIFT
-#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN((typeof(PAGE_SIZE))addr)
+#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN((typeof(PAGE_SIZE))(addr))
 
 /* SGE ring related macros */
 #define NUM_RX_SGE_PAGES		2
-- 
1.5.4.3




