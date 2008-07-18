From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH v2 2/4] I/OAT: Increase sleep time in ioat_dma_self_test
Date: Fri, 18 Jul 2008 17:28:30 +0200
Message-ID: <20080718152801.21235.80935.stgit@linux.site>
References: <20080718152541.21235.85961.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29087 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754895AbYGRPiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 11:38:20 -0400
In-Reply-To: <20080718152541.21235.85961.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sleep time in self_test has been increased to 10ms
since in some cases 1ms appeared not to be enough.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dma/ioat_dma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index f1d6382..2fe3aac 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -1331,7 +1331,7 @@ static int ioat_dma_self_test(struct ioa
 		goto free_resources;
 	}
 	device->common.device_issue_pending(dma_chan);
-	msleep(1);
+	msleep(10);
 
 	if (device->common.device_is_tx_complete(dma_chan, cookie, NULL, NULL)
 					!= DMA_SUCCESS) {

