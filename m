From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] vmxnet3: Fix typo in vmxnet3_drv.c
Date: Wed,  1 Feb 2012 22:13:59 +0900
Message-ID: <1328102039-1806-1-git-send-email-standby24x7@gmail.com>
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	standby24x7@gmail.com
To: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from i118-21-156-233.s30.a048.ap.plala.or.jp ([118.21.156.233]:41474
	"EHLO rinabert.homeip.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754534Ab2BANOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 08:14:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct spelling in "uncommited" to "uncommitted" in
drivers/net/vmxnet3/vmxnet3_drv.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index de7fc34..16cbbce 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -636,7 +636,7 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 
 	dev_dbg(&adapter->netdev->dev,
 		"alloc_rx_buf: %d allocated, next2fill %u, next2comp "
-		"%u, uncommited %u\n", num_allocated, ring->next2fill,
+		"%u, uncommitted %u\n", num_allocated, ring->next2fill,
 		ring->next2comp, rq->uncommitted[ring_idx]);
 
 	/* so that the device can distinguish a full ring and an empty ring */
-- 
1.7.6.5
