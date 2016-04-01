From: roy.qing.li@gmail.com
Subject: [PATCH] bridge: remove br_dev_set_multicast_list
Date: Fri,  1 Apr 2016 16:16:10 +0800
Message-ID: <1459498570-30664-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46259 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbcDAIQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 04:16:12 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.186])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id u318GBpQ002861
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 01:16:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

remove br_dev_set_multicast_list which does nothing

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/bridge/br_device.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 2c8095a..75c7e00 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -123,10 +123,6 @@ static int br_dev_open(struct net_device *dev)
 	return 0;
 }
 
-static void br_dev_set_multicast_list(struct net_device *dev)
-{
-}
-
 static void br_dev_change_rx_flags(struct net_device *dev, int change)
 {
 	if (change & IFF_PROMISC)
@@ -329,7 +325,6 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_start_xmit		 = br_dev_xmit,
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
-	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
 	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
-- 
2.1.4
