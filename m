From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/11 RESEND] cxgb3 - Update rx coalescing length
Date: Tue, 21 Aug 2007 20:49:05 -0700
Message-ID: <20070822034905.9260.77225.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:23568 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbXHVDtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:49:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Reduce Rx coalescing length to 12288
Large bursts from the adapter to the host create back pressure
on the chip. Reducing the burst size avoids the issue.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index c46c249..55922ed 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -104,7 +104,7 @@ enum {
 	PROTO_SRAM_LINES = 128, /* size of TP sram */
 };
 
-#define MAX_RX_COALESCING_LEN 16224U
+#define MAX_RX_COALESCING_LEN 12288U
 
 enum {
 	PAUSE_RX = 1 << 0,
