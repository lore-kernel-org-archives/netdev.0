From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] small netdevices.txt fix
Date: Wed, 16 May 2007 14:59:04 +0200
Message-ID: <20070516125904.GA1322@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:43097 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812AbXEPM7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 08:59:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/Documentation/networking/netdevices.txt
===================================================================
--- linux-2.6.orig/Documentation/networking/netdevices.txt	2007-01-04 19:38:05.000000000 +0100
+++ linux-2.6/Documentation/networking/netdevices.txt	2007-01-04 19:40:22.000000000 +0100
@@ -49,7 +49,7 @@
 	for this and return -1 when the spin lock fails. 
 	The locking there should also properly protect against 
 	set_multicast_list
-	Context: BHs disabled
+	Context: Process with BHs disabled or BH (timer).
 	Notes: netif_queue_stopped() is guaranteed false
                Interrupts must be enabled when calling hard_start_xmit.
                 (Interrupts must also be enabled when enabling the BH handler.)
