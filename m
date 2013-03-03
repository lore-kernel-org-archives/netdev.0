From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] CAIF: fix sparse warning for caif_usb
Date: Sun,  3 Mar 2013 15:09:48 +0200
Message-ID: <1362316188-2927-1-git-send-email-silviupopescu1990@gmail.com>
Cc: sjur.brandeland@stericsson.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the following sparse warning:
net/caif/caif_usb.c:84:16: warning: symbol 'cfusbl_create' was not
declared. Should it be static?

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 net/caif/caif_usb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 3ebc8cb..cbae9b0 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -81,7 +81,7 @@ static void cfusbl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
 }
 
-struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
+static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
 					u8 braddr[ETH_ALEN])
 {
 	struct cfusbl *this = kmalloc(sizeof(struct cfusbl), GFP_ATOMIC);
-- 
1.7.9.5
