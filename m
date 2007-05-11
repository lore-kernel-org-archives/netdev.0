From: akpm@linux-foundation.org
Subject: [patch 13/13] mlx4: don't use deprecated IRQ flags
Date: Thu, 10 May 2007 22:53:01 -0700
Message-ID: <200705110553.l4B5r1Gp007828@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:38181 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754568AbXEKGI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:08:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/mlx4/eq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/mlx4/eq.c~mlx4-dont-use-deprecated-irq-flags drivers/net/mlx4/eq.c
--- a/drivers/net/mlx4/eq.c~mlx4-dont-use-deprecated-irq-flags
+++ a/drivers/net/mlx4/eq.c
@@ -623,7 +623,7 @@ int __devinit mlx4_init_eq_table(struct 
 		priv->eq_table.eq[MLX4_EQ_CATAS].have_irq = 1;
 	} else {
 		err = request_irq(dev->pdev->irq, mlx4_interrupt,
-				  SA_SHIRQ, DRV_NAME, dev);
+				  IRQF_SHARED, DRV_NAME, dev);
 		if (err)
 			goto err_out_async;
 
_
