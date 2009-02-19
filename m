From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 05/12]Replace all DMA_35BIT_MASK micro with DMA_BIT_MASK(35)
Date: Thu, 19 Feb 2009 14:45:21 +0800
Message-ID: <499D0001.7090208@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64029 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751896AbZBSGny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:43:54 -0500
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_35BIT_MASK micro with DMA_BIT_MASK(35)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/netxen/netxen_nic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8bea4cb..2d4e41b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -183,8 +183,8 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 		adapter->dma_mask = DMA_BIT_MASK(39);
 		mask = DMA_BIT_MASK(39);
 	} else if (revision_id == NX_P2_C1) {
-		adapter->dma_mask = DMA_35BIT_MASK;
-		mask = DMA_35BIT_MASK;
+		adapter->dma_mask = DMA_BIT_MASK(35);
+		mask = DMA_BIT_MASK(35);
 	} else {
 		adapter->dma_mask = DMA_32BIT_MASK;
 		mask = DMA_32BIT_MASK;
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
