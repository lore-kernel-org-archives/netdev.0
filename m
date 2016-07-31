From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1 v2] dsa: b53: remove redundant if
Date: Sun, 31 Jul 2016 13:42:33 +0200
Message-ID: <1469965353-3496-1-git-send-email-xypron.glpk@gmx.de>
References: <a26b33b7-f051-b84c-684a-abb586991513@cogentembedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:56174 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbcGaLmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 07:42:43 -0400
In-Reply-To: <a26b33b7-f051-b84c-684a-abb586991513@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For pdata == null the code leaves with an error.
There is no need to check the condition again.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/dsa/b53/b53_mmap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
index 21f1068..77ffc43 100644
--- a/drivers/net/dsa/b53/b53_mmap.c
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -233,8 +233,7 @@ static int b53_mmap_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
-	if (pdata)
-		dev->pdata = pdata;
+	dev->pdata = pdata;
 
 	platform_set_drvdata(pdev, dev);
 
-- 
2.8.1
