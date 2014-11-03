From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] hamradio: 6pack: remove unnecessary check
Date: Mon,  3 Nov 2014 17:42:29 +0530
Message-ID: <1415016749-6825-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andreas Koensgen <ajk@comnets.uni-bremen.de>
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this is check for dev is unnecessary, as we are already checking dev
after allocating it via alloc_netdev, and jumping to label: out
if it is NULL.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/hamradio/6pack.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index c3c4051..daca0de 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -675,8 +675,7 @@ out_free:
 	kfree(xbuff);
 	kfree(rbuff);
 
-	if (dev)
-		free_netdev(dev);
+	free_netdev(dev);
 
 out:
 	return err;
-- 
1.8.1.2

