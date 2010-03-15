From: Dan Carpenter <error27@gmail.com>
Subject: [patch] myri: remove dead code
Date: Mon, 15 Mar 2010 11:24:08 +0300
Message-ID: <20100315082408.GG18181@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <brice@myri.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:48336 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759859Ab0COIYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 04:24:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can never reach the return statement.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 676c513..e84dd3e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3687,7 +3687,6 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 	if (status != 0) {
 		dev_err(&mgp->pdev->dev, "failed reset\n");
 		goto abort_with_fw;
-		return;
 	}
 
 	mgp->max_intr_slots = cmd.data0 / sizeof(struct mcp_slot);
