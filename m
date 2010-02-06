From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 3/6] dmfe: workaround chipset bug
Date: Sat,  6 Feb 2010 22:18:59 +0200
Message-ID: <1265487542-4447-4-git-send-email-maximlevitsky@gmail.com>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:47029 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993Ab0BFUTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2010 15:19:17 -0500
In-Reply-To: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On my system the network card won't work at all if
it issues PCI READ MULTIPLY commands, so disable it
this shouldn't give any preformance impact

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/net/tulip/dmfe.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/dmfe.h b/drivers/net/tulip/dmfe.h
index 3bd2d87..d12227d 100644
--- a/drivers/net/tulip/dmfe.h
+++ b/drivers/net/tulip/dmfe.h
@@ -76,7 +76,7 @@
 #define TX_BUF_ALLOC    0x600
 #define RX_ALLOC_SIZE   0x620
 #define DM910X_RESET    1
-#define CR0_DEFAULT     0x00E00000      /* TX & RX burst mode */
+#define CR0_DEFAULT     0x00C00000      /* TX & RX burst mode */
 #define CR6_DEFAULT     0x00080000      /* HD */
 #define CR7_DEFAULT     0x180c1
 #define CR15_DEFAULT    0x06            /* TxJabber RxWatchdog */
-- 
1.6.3.3

