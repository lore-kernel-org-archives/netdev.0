From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH]   Increase no descriptors on max.
Date: Tue,  1 Mar 2016 09:25:58 +0200
Message-ID: <1456817158-1978-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.78.245.130] ([82.78.245.130]:55144 "EHLO marian1000.go.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbcCAH04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 02:26:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This patch increase rx/tx on maximum allowed 1024 4-duble-words
  descriptors.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e215812..5fd3fca 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -84,8 +84,8 @@ static const int multicast_filter_limit = 32;
 
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
-#define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
-#define NUM_RX_DESC	256U	/* Number of Rx descriptor registers */
+#define NUM_TX_DESC	1024	/* Number of Tx descriptor registers */
+#define NUM_RX_DESC	1024U	/* Number of Rx descriptor registers */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
-- 
2.1.4
