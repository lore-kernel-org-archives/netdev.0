From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (14/16) smsc-ircc2 - whitespace and indentation
Date: Tue, 30 Sep 2003 15:17:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930151701.1886d195.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Small whitespace and indentation fix for readablity

diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:29:39 2003
+++ b/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:29:39 2003
@@ -375,7 +375,7 @@
 		goto err_out;
 		
 	err = -ENOMEM;
-	if (dev_count>DIM(dev_self)) {
+	if (dev_count > DIM(dev_self)) {
 	        WARNING("%s(), too many devices!\n", __FUNCTION__);
 		goto err_out1;
 	}
@@ -407,8 +407,12 @@
 		
 	smsc_ircc_init_chip(self);
 	
-	if(ircc_transceiver > 0 && ircc_transceiver < SMSC_IRCC2_C_NUMBER_OF_TRANSCEIVERS) self->transceiver = ircc_transceiver;
-	else smsc_ircc_probe_transceiver(self);
+	if(ircc_transceiver > 0  && 
+	   ircc_transceiver < SMSC_IRCC2_C_NUMBER_OF_TRANSCEIVERS)
+		self->transceiver = ircc_transceiver;
+	else
+		smsc_ircc_probe_transceiver(self);
+
 
 	err = smsc_ircc_setup_netdev(self);
 	if(err) 
