From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] net, sja1000: Don't include version.h in peak_pci.c when
 not needed
Date: Sun, 20 Nov 2011 22:07:09 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1111202204480.17195@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was pointed out by "make versioncheck" that we do not need to include
version.h in drivers/net/can/sja1000/peak_pci.c
This patch removes the unneeded include.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/can/sja1000/peak_pci.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

 note: patch is compile tested only.

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 905bce0..2c7f503 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -20,7 +20,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
-- 
1.7.7.3


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

