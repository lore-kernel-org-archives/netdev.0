From: sjur.brandeland@stericsson.com
Subject: [net 3/3] caif-hsi: Add missing return in error path
Date: Sun, 24 Jun 2012 23:01:38 +0200
Message-ID: <1340571698-17892-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60193 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab2FXVBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 17:01:48 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so5685469lbb.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 14:01:47 -0700 (PDT)
In-Reply-To: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

=46ix a missing return, causing access to freed memory.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 1f52ff3..4a27adb 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1178,6 +1178,7 @@ int cfhsi_probe(struct platform_device *pdev)
 		dev_err(&ndev->dev, "%s: Registration error: %d.\n",
 			__func__, res);
 		free_netdev(ndev);
+		return -ENODEV;
 	}
 	/* Add CAIF HSI device to list. */
 	spin_lock(&cfhsi_list_lock);
--=20
1.7.5.4
