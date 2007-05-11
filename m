From: akpm@linux-foundation.org
Subject: [patch 12/13] netxen_nic_main don't use deprecated irq flags
Date: Thu, 10 May 2007 22:53:00 -0700
Message-ID: <200705110553.l4B5r0A3007825@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43862 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755439AbXEKGJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:09:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/netxen/netxen_nic_main.c: In function 'netxen_nic_open':
drivers/net/netxen/netxen_nic_main.c:738: warning: 'deprecated_irq_flag' is deprecated (declared at include/linux/interrupt.h:66)
drivers/net/netxen/netxen_nic_main.c:738: warning: 'deprecated_irq_flag' is deprecated (declared at include/linux/interrupt.h:66)

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/netxen/netxen_nic_main.c~netxen_nic_main-dont-use-deprecated-irq-flags drivers/net/netxen/netxen_nic_main.c
--- a/drivers/net/netxen/netxen_nic_main.c~netxen_nic_main-dont-use-deprecated-irq-flags
+++ a/drivers/net/netxen/netxen_nic_main.c
@@ -735,7 +735,7 @@ static int netxen_nic_open(struct net_de
 		}
 		adapter->irq = adapter->ahw.pdev->irq;
 		err = request_irq(adapter->ahw.pdev->irq, netxen_intr,
-				  SA_SHIRQ | SA_SAMPLE_RANDOM, netdev->name,
+				  IRQF_SHARED|IRQF_SAMPLE_RANDOM, netdev->name,
 				  adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
_
