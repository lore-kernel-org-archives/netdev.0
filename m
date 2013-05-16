From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH 1/5] davinci: net: cpdma: remove unwanted header file incusion and sort thme alphabetically
Date: Thu, 16 May 2013 13:00:34 +0530
Message-ID: <1368689438-23889-2-git-send-email-prabhakar.csengg@gmail.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:40024 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab3EPHbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 03:31:04 -0400
In-Reply-To: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 49dfd59..f7ce97f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -12,15 +12,11 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  */
-#include <linux/kernel.h>
-#include <linux/spinlock.h>
-#include <linux/device.h>
+
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/err.h>
-#include <linux/dma-mapping.h>
-#include <linux/io.h>
-#include <linux/delay.h>
 
 #include "davinci_cpdma.h"
 
-- 
1.7.4.1
