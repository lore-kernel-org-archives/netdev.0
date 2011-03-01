From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 3/5] tg3: Enclose macro with complex values in parenthesis
Date: Tue,  1 Mar 2011 18:04:27 +0100
Message-ID: <1298999069-12740-3-git-send-email-martinez.javier@gmail.com>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, kernelnewbies@kernelnewbies.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64995 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756998Ab1CARE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 12:04:26 -0500
Received: by eyx24 with SMTP id 24so1742045eyx.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 09:04:25 -0800 (PST)
In-Reply-To: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macros with complex values should be enclosed in parenthesis.
Change accordingly.

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/tg3.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6dc7a8a..c67eb19 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -513,16 +513,16 @@ static void tg3_write32_mbox_5906(struct tg3 *tp, u32 off, u32 val)
 	writel(val, tp->regs + off + GRCMBOX_BASE);
 }
 
-#define tw32_mailbox(reg, val)		tp->write32_mbox(tp, reg, val)
+#define tw32_mailbox(reg, val)		(tp->write32_mbox(tp, reg, val))
 #define tw32_mailbox_f(reg, val)	tw32_mailbox_flush(tp, (reg), (val))
-#define tw32_rx_mbox(reg, val)		tp->write32_rx_mbox(tp, reg, val)
-#define tw32_tx_mbox(reg, val)		tp->write32_tx_mbox(tp, reg, val)
-#define tr32_mailbox(reg)		tp->read32_mbox(tp, reg)
+#define tw32_rx_mbox(reg, val)		(tp->write32_rx_mbox(tp, reg, val))
+#define tw32_tx_mbox(reg, val)		(tp->write32_tx_mbox(tp, reg, val))
+#define tr32_mailbox(reg)		(tp->read32_mbox(tp, reg))
 
-#define tw32(reg, val)			tp->write32(tp, reg, val)
+#define tw32(reg, val)			(tp->write32(tp, reg, val))
 #define tw32_f(reg, val)		_tw32_flush(tp, (reg), (val), 0)
 #define tw32_wait_f(reg, val, us)	_tw32_flush(tp, (reg), (val), (us))
-#define tr32(reg)			tp->read32(tp, reg)
+#define tr32(reg)			(tp->read32(tp, reg))
 
 static void tg3_write_mem(struct tg3 *tp, u32 off, u32 val)
 {
-- 
1.7.2.3

