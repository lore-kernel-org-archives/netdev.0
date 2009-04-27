From: Mike Rapoport <mike@compulab.co.il>
Subject: [PATCH] fix typo in net_device_ops description
Date: Mon, 27 Apr 2009 13:54:59 +0300
Message-ID: <49F58F03.8090400@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cathcart.site5.com ([74.54.107.137]:51443 "EHLO
	cathcart.site5.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbZD0LWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 07:22:03 -0400
Received: from [192.114.83.142] (helo=mail.linux-boards.com)
	by cathcart.site5.com with esmtpsa (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.69)
	(envelope-from <mike@compulab.co.il>)
	id 1LyOUK-0000m9-5x
	for netdev@vger.kernel.org; Mon, 27 Apr 2009 05:55:05 -0500
Received: from [10.1.1.95] (mike-pc.compulab.local [10.1.1.95])
	by mail.linux-boards.com (8.12.5/8.12.8) with ESMTP id n3RAsxXI004458
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 13:54:59 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike@compulab.co.il>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..5991399 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -500,7 +500,7 @@ struct netdev_queue {
  *
  * int (*ndo_set_mac_address)(struct net_device *dev, void *addr);
  *	This function  is called when the Media Access Control address
- *	needs to be changed. If not this interface is not defined, the
+ *	needs to be changed. If this interface is not defined, the
  *	mac address can not be changed.
  *
  * int (*ndo_validate_addr)(struct net_device *dev);

-- 
Sincerely yours,
Mike.

