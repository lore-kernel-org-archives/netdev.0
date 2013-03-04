From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH v3] CAIF: fix sparse warning for caif_usb
Date: Mon,  4 Mar 2013 09:09:31 +0200
Message-ID: <1362380971-23007-1-git-send-email-silviupopescu1990@gmail.com>
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
 net/caif/caif_usb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 3ebc8cb..1c6ded9 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -81,8 +81,8 @@ static void cfusbl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
 }
 
-struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
-					u8 braddr[ETH_ALEN])
+static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
+				      u8 braddr[ETH_ALEN])
 {
 	struct cfusbl *this = kmalloc(sizeof(struct cfusbl), GFP_ATOMIC);
 
-- 
1.7.9.5
