From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/4] sis190: remove duplicate INIT_WORK
Date: Mon, 10 Dec 2007 23:30:18 +0100
Message-ID: <20071210223018.GC8675@electric-eye.fr.zoreil.com>
References: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50886 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751600AbXLJWgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 17:36:43 -0500
Content-Disposition: inline
In-Reply-To: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is already done in sis190_init_one.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: K.M. Liu <kmliu@sis.com.tw>
---
 drivers/net/sis190.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 51bbb60..f6a921c 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1041,8 +1041,6 @@ static int sis190_open(struct net_device *dev)
 	if (rc < 0)
 		goto err_free_rx_1;
 
-	INIT_WORK(&tp->phy_task, sis190_phy_task);
-
 	sis190_request_timer(dev);
 
 	rc = request_irq(dev->irq, sis190_interrupt, IRQF_SHARED, dev->name, dev);
-- 
1.5.3.3

