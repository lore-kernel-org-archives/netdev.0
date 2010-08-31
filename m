From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: make rx_queue sysfs_ops const
Date: Tue, 31 Aug 2010 15:14:13 -0700
Message-ID: <20100831151413.3adb0ea1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41386 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097Ab0HaWOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 18:14:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/net-sysfs.c	2010-08-31 15:09:51.280223081 -0700
+++ b/net/core/net-sysfs.c	2010-08-31 15:10:03.820257477 -0700
@@ -515,7 +515,7 @@ static ssize_t rx_queue_attr_store(struc
 	return attribute->store(queue, attribute, buf, count);
 }
 
-static struct sysfs_ops rx_queue_sysfs_ops = {
+static const struct sysfs_ops rx_queue_sysfs_ops = {
 	.show = rx_queue_attr_show,
 	.store = rx_queue_attr_store,
 };
