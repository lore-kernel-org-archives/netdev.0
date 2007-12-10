From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/4] sis190: mdio operation failure is not correctly
	detected
Date: Mon, 10 Dec 2007 23:31:02 +0100
Message-ID: <20071210223102.GD8675@electric-eye.fr.zoreil.com>
References: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50902 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751807AbXLJWh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 17:37:27 -0500
Content-Disposition: inline
In-Reply-To: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i ranges from 0 to 100 in the 'for' loop a few lines above.

Reported by davem.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: K.M. Liu <kmliu@sis.com.tw>
---
 drivers/net/sis190.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index f6a921c..973b369 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -372,7 +372,7 @@ static void __mdio_cmd(void __iomem *ioaddr, u32 ctl)
 		msleep(1);
 	}
 
-	if (i > 999)
+	if (i > 99)
 		printk(KERN_ERR PFX "PHY command failed !\n");
 }
 
-- 
1.5.3.3

