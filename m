From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] xen-netback: fix sparse warning
Date: Thu,  5 Feb 2015 13:38:07 +0000
Message-ID: <1423143487-4722-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

interface.c:83:5: warning: symbol 'xenvif_poll' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.9.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/xen-netback/interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 12f9e27..f38227a 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -80,7 +80,7 @@ static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-int xenvif_poll(struct napi_struct *napi, int budget)
+static int xenvif_poll(struct napi_struct *napi, int budget)
 {
 	struct xenvif_queue *queue =
 		container_of(napi, struct xenvif_queue, napi);
-- 
1.9.1
