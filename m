From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] dm9000: fix compilation
Date: Sat, 15 Nov 2008 21:37:30 +0300
Message-ID: <20081115183730.GA2639@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:39449 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbYKOSeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 13:34:02 -0500
Received: by ug-out-1314.google.com with SMTP id 39so132847ugf.37
        for <netdev@vger.kernel.org>; Sat, 15 Nov 2008 10:34:01 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/dm9000.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1447,7 +1447,7 @@ dm9000_drv_remove(struct platform_device *pdev)
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
-	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev);
+	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev));
 	free_netdev(ndev);		/* free device structure */
 
 	dev_dbg(&pdev->dev, "released and freed device\n");
