From: Yegor Yefremov <yegor_sub1@visionsystems.de>
Subject: Re: [PATCH net-next-2.6 1/2] can: sja1000: allow shared interrupt
 definition
Date: Fri, 19 Mar 2010 11:49:08 +0100
Message-ID: <4BA356A4.5040205@visionsystems.de>
References: <4BA3565F.6040907@visionsystems.de>
Reply-To: yegor_sub1@visionsystems.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hhlx01.vscom.de ([62.145.30.242]:34854 "EHLO
	mail.visionsystems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab0CSKtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 06:49:33 -0400
In-Reply-To: <4BA3565F.6040907@visionsystems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SJA1000: allow shared interrupt definition

extend the AND mask, so that IRQF_SHARED flag remains

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 628374c..bec0d3d 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -90,7 +90,7 @@ static int sp_probe(struct platform_device *pdev)
 	priv = netdev_priv(dev);
 
 	dev->irq = res_irq->start;
-	priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
+	priv->irq_flags = res_irq->flags & (IRQF_TRIGGER_MASK | IRQF_SHARED);
 	priv->reg_base = addr;
 	priv->read_reg = sp_read_reg;
 	priv->write_reg = sp_write_reg;

