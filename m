From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] tg3: remove extra casting
Date: Mon, 19 Jan 2009 22:00:54 +0100
Message-ID: <20090119210054.GA6158@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42941 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753403AbZASU71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 15:59:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5e2dbae..a925216 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -860,7 +860,7 @@ static int tg3_bmcr_reset(struct tg3 *tp)
 
 static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
 {
-	struct tg3 *tp = (struct tg3 *)bp->priv;
+	struct tg3 *tp = bp->priv;
 	u32 val;
 
 	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
@@ -874,7 +874,7 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
 
 static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
 {
-	struct tg3 *tp = (struct tg3 *)bp->priv;
+	struct tg3 *tp = bp->priv;
 
 	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
 		return -EAGAIN;
-- 
1.6.0.6

