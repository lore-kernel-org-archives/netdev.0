From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] packetengines: fix config default
Date: Fri, 2 Mar 2012 15:38:56 -0800
Message-ID: <20120302153856.4352ae3c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39870 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965541Ab2CBXi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 18:38:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of the big network driver reorg, each vendor directory defaults to
yes, so that older config's can migrate correctly. Looks like this one
got missed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Patch should go to -net for 3.3


--- a/drivers/net/ethernet/packetengines/Kconfig	2012-01-10 10:56:56.891156428 -0800
+++ b/drivers/net/ethernet/packetengines/Kconfig	2012-03-02 15:35:26.611294060 -0800
@@ -4,6 +4,7 @@
 
 config NET_PACKET_ENGINE
 	bool "Packet Engine devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
