From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sk98lin: planned removal
Date: Fri, 16 Feb 2007 15:07:53 -0800
Message-ID: <20070216150753.176bb5c0@localhost.localdomain>
References: <20070207091830.59f72f46@oldman>
	<20070207203215.bdf3908b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40721 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbXBPXJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 18:09:41 -0500
In-Reply-To: <20070207203215.bdf3908b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nag message about planned sk98lin removal.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- skge.orig/drivers/net/sk98lin/skge.c
+++ skge/drivers/net/sk98lin/skge.c
@@ -5188,6 +5188,9 @@ static struct pci_driver skge_driver = {
 
 static int __init skge_init(void)
 {
+	printk(KERN_NOTICE "sk98lin: driver has been replaced by the skge driver"
+	       " and is scheduled for removal\n");
+
 	return pci_register_driver(&skge_driver);
 }
 
