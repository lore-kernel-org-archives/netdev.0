From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] ieee1394: remove unneeded last_rx
Date: Tue, 6 Jan 2009 14:55:54 -0800
Message-ID: <20090106145554.53ef1ccc@extreme>
References: <20090106145456.37ecedaa@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: krh@redhat.com, stefanr@s5r6.in-berlin.de,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50028 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbZAFW4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 17:56:55 -0500
In-Reply-To: <20090106145456.37ecedaa@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last_rx is now done if needed inside bonding.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/ieee1394/eth1394.c	2009-01-03 20:19:30.123514679 -0800
+++ b/drivers/ieee1394/eth1394.c	2009-01-03 20:21:51.018766544 -0800
@@ -1234,8 +1238,6 @@ bad_proto:
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
 
-	dev->last_rx = jiffies;
-
 	return 0;
 }
 
