From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] vlan: static functions
Date: Wed, 14 Dec 2011 07:57:54 +0100
Message-ID: <1323845874.2846.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Benjamin LaHaise <bcrl@kvack.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:42938 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab1LNG6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 01:58:00 -0500
Received: by wgbds13 with SMTP id ds13so834372wgb.1
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 22:57:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6d4cdf47d2 (vlan: add 802.1q netpoll support) forgot to declare
as static some private functions.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Benjamin LaHaise <bcrl@kvack.org> 
---
 net/8021q/vlan_dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 0390139..9988d4a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -664,12 +664,12 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-void vlan_dev_poll_controller(struct net_device *dev)
+static void vlan_dev_poll_controller(struct net_device *dev)
 {
 	return;
 }
 
-int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo)
+static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo)
 {
 	struct vlan_dev_priv *info = vlan_dev_priv(dev);
 	struct net_device *real_dev = info->real_dev;
@@ -696,7 +696,7 @@ out:
 	return err;
 }
 
-void vlan_dev_netpoll_cleanup(struct net_device *dev)
+static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 {
 	struct vlan_dev_priv *info = vlan_dev_priv(dev);
 	struct netpoll *netpoll = info->netpoll;
