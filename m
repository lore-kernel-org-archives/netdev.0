From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 07/21] e1000: change printk into DPRINTK
Date: Wed, 21 Jun 2006 22:20:20 -0700
Message-ID: <20060622052020.25497.87732.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:48648 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030306AbWFVFOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:23 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Changing a printk message to make clear that this message is originating
from e1000.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ea18f30..fc39cbc 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2841,7 +2841,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 			case e1000_82573:
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					printk(KERN_ERR
+					DPRINTK(DRV, ERR,
 						"__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;



--
Auke Kok <auke-jan.h.kok@intel.com>
