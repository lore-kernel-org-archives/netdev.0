From: "Alexandre Bounine" <Alexandre.Bounine@tundra.com>
Subject: [PATCH 1/5] Tsi108_eth: add missing linking to driver data
Date: Fri, 8 Feb 2008 14:16:55 -0500
Message-ID: <1B5F013528140F45B5C671039279CA5702A9609F@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>,
	"Zang Roy-r61911" <tie-fei.zang@freescale.com>
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tundra.com ([142.46.200.162]:48732 "EHLO mx2.tundra.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763244AbYBHT3s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 14:29:48 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix for tsi108_eth network driver.
This patch adds missing linking to driver data. 
   
Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-01-24
17:58:37.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
14:30:04.000000000 -0500
@@ -1629,6 +1629,7 @@ tsi108_init_one(struct platform_device *
 		goto register_fail;
 	}
 
+	platform_set_drvdata(pdev, dev);
 	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
 	       dev->name, print_mac(mac, dev->dev_addr));
 #ifdef DEBUG



---



Important Notice: This message is intended for the use of the individual to whom it is addressed and may contain information which is privileged, confidential and/or exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, or is not the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by telephone or return e-mail and delete the original message from your systems. Thank you. 


