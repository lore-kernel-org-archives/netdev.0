From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: Cosmetic changes to N2 and C101 drivers
Date: Sun, 16 Jul 2006 14:19:07 +0200
Message-ID: <m31wsln3no.fsf@defiant.localdomain>
References: <m3veq3suve.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:29657 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S964846AbWGPMTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2006 08:19:10 -0400
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
In-Reply-To: <m3veq3suve.fsf@defiant.localdomain> (Krzysztof Halasa's message of "Tue, 11 Jul 2006 23:18:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WAN: Cosmetic changes to N2 and C101 drivers

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 3796a59..2911be3 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -197,7 +197,6 @@ static int c101_open(struct net_device *
 	sca_out(IE0_TXINT, MSCI0_OFFSET + IE0, port);
 
 	set_carrier(port);
-	printk(KERN_DEBUG "0x%X\n", sca_in(MSCI1_OFFSET + ST3, port));
 
 	/* enable MSCI1 CDCD interrupt */
 	sca_out(IE1_CDCD, MSCI1_OFFSET + IE1, port);
@@ -449,4 +448,5 @@ module_exit(c101_cleanup);
 MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("Moxa C101 serial port driver");
 MODULE_LICENSE("GPL v2");
-module_param(hw, charp, 0444);	/* hw=irq,ram:irq,... */
+module_param(hw, charp, 0444);
+MODULE_PARM_DESC(hw, "irq,ram:irq,...");
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index cd32751..0a17ad6 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -559,4 +559,5 @@ module_exit(n2_cleanup);
 MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("RISCom/N2 serial port driver");
 MODULE_LICENSE("GPL v2");
-module_param(hw, charp, 0444);	/* hw=io,irq,ram,ports:io,irq,... */
+module_param(hw, charp, 0444);
+MODULE_PARM_DESC(hw, "io,irq,ram,ports:io,irq,...");
