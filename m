From: Joe Perches <joe@perches.com>
Subject: [PATCH] caif: Fix recieve/receive typo
Date: Fri, 24 Jun 2011 10:59:19 -0700
Message-ID: <661bd38a1d84b746ad6879baf83b3a98c93676e6.1308938176.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3202 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab1FXR7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 13:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just spelling fixes.

Actually, a twofer with vaiables/variables as well.

Signed-off-by: Joe Perches <joe@perches.com>
---
Remainder patch.  Jiri doesn't track -next.

 drivers/net/caif/caif_hsi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 7a8ce612..fda0b1f 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -988,8 +988,7 @@ int cfhsi_probe(struct platform_device *pdev)
 		goto err_alloc_rx;
 	}
 
-	/* Initialize recieve vaiables. */
+	/* Initialize receive variables. */
 	cfhsi->rx_ptr = cfhsi->rx_buf;
 	cfhsi->rx_len = CFHSI_DESC_SZ;
 
-- 
1.7.6.rc3

