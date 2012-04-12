From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 3/3] caif_hsi: use dev_dbg not dev_err for reporting
Date: Thu, 12 Apr 2012 20:18:09 +0200
Message-ID: <1334254689-2843-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Cc: sjurbren@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48427 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932923Ab2DLSST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:18:19 -0400
Received: by lbbgm6 with SMTP id gm6so1835980lbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:18:18 -0700 (PDT)
In-Reply-To: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Use dev_dbg instead of dev_err for reporting in cfhsi_wakeup_cb.

Signed-off-by: Kim Lilliestierna <kim.xx.lilliestierna@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index d0d9a6f..9c1c8cd 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -744,14 +744,14 @@ static void cfhsi_wake_up(struct work_struct *work)
 		size_t fifo_occupancy = 0;
 
 		/* Wakeup timeout */
-		dev_err(&cfhsi->ndev->dev, "%s: Timeout.\n",
+		dev_dbg(&cfhsi->ndev->dev, "%s: Timeout.\n",
 			__func__);
 
 		/* Check FIFO to check if modem has sent something. */
 		WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
 					&fifo_occupancy));
 
-		dev_err(&cfhsi->ndev->dev, "%s: Bytes in FIFO: %u.\n",
+		dev_dbg(&cfhsi->ndev->dev, "%s: Bytes in FIFO: %u.\n",
 				__func__, (unsigned) fifo_occupancy);
 
 		/* Check if we misssed the interrupt. */
-- 
1.7.5.4
