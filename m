From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 16/26] e100: remove skb->dev assignment
Date: Tue, 29 Aug 2006 09:44:50 -0700
Message-ID: <20060829164450.6872.69387.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:47370 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965092AbWH2Qgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:36 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index eb467f8..a98e23a 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1763,7 +1763,6 @@ static int e100_rx_alloc_skb(struct nic 
 		return -ENOMEM;
 
 	/* Align, init, and map the RFD. */
-	rx->skb->dev = nic->netdev;
 	skb_reserve(rx->skb, NET_IP_ALIGN);
 	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,



---
Auke Kok <auke-jan.h.kok@intel.com>
