From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 03/27] drivers/net: fix sparse warning: returning void-valued
	expression
Date: Mon, 22 Dec 2008 20:15:17 +0100
Message-ID: <20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:19066 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242AbYLVTPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:15:24 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warning:

  drivers/net/niu.c:8850:2: warning: returning void-valued expression

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 022866d..a4b6913 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -8847,7 +8847,7 @@ static u64 niu_pci_map_page(struct device *dev, struct page *page,
 static void niu_pci_unmap_page(struct device *dev, u64 dma_address,
 			       size_t size, enum dma_data_direction direction)
 {
-	return dma_unmap_page(dev, dma_address, size, direction);
+	dma_unmap_page(dev, dma_address, size, direction);
 }
 
 static u64 niu_pci_map_single(struct device *dev, void *cpu_addr,

