From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 2/2 net-next] caif_usb: use target structure member in memset
Date: Tue, 14 Oct 2014 19:01:14 +0200
Message-ID: <1413306074-8401-1-git-send-email-fabf@skynet.be>
Cc: Joe Perches <joe@perches.com>, Fabian Frederick <fabf@skynet.be>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

parent cfusbl was used instead of first structure member 'layer'

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/caif/caif_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 0e487b0..5cd44f0 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -92,7 +92,7 @@ static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
 
 	caif_assert(offsetof(struct cfusbl, layer) == 0);
 
-	memset(this, 0, sizeof(struct cflayer));
+	memset(&this->layer, 0, sizeof(this->layer));
 	this->layer.receive = cfusbl_receive;
 	this->layer.transmit = cfusbl_transmit;
 	this->layer.ctrlcmd = cfusbl_ctrlcmd;
-- 
1.9.3
