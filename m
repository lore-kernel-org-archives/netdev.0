From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] irda: fix smsc-ircc2 section mismatch warning
Date: Tue, 21 Jun 2011 12:39:38 -0700
Message-ID: <20110621123938.5c932de8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, Samuel Ortiz <samuel@sortiz.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25780 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757486Ab1FUTkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 15:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix section mismatch warning:

WARNING: drivers/net/irda/smsc-ircc2.o(.devinit.text+0x1a7): Section mismatch in reference from the function smsc_ircc_pnp_probe() to the function .init.text:smsc_ircc_open()

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/irda/smsc-ircc2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-30-rc4.orig/drivers/net/irda/smsc-ircc2.c
+++ lnx-30-rc4/drivers/net/irda/smsc-ircc2.c
@@ -515,7 +515,7 @@ static const struct net_device_ops smsc_
  *    Try to open driver instance
  *
  */
-static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
+static int __devinit smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
 {
 	struct smsc_ircc_cb *self;
 	struct net_device *dev;
