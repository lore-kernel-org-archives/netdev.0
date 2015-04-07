From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] netdevice.h: remove iflink description
Date: Tue,  7 Apr 2015 12:10:16 +0200
Message-ID: <1428401416-27626-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:59921 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbDGKKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 06:10:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also move 'group' description to match the order of the net_device structure.

Fixes: 7a66bbc96ce9 ("net: remove iflink field from struct net_device")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

As it's only a documentation fix and we are close to the release, I target
this to net-next.

 include/linux/netdevice.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 41bf58a2b936..e8591d548f68 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1328,7 +1328,7 @@ enum netdev_priv_flags {
  *	@mpls_features:	Mask of features inheritable by MPLS
  *
  *	@ifindex:	interface index
- *	@iflink:	unique device identifier
+ *	@group:		The group, that the device belongs to
  *
  *	@stats:		Statistics struct, which was left as a legacy, use
  *			rtnl_link_stats64 instead
@@ -1488,7 +1488,6 @@ enum netdev_priv_flags {
  *
  *	@qdisc_tx_busylock:	XXX: need comments on this one
  *
- *	@group:		The group, that the device belongs to
  *	@pm_qos_req:	Power Management QoS object
  *
  *	FIXME: cleanup struct net_device such that network protocol info
-- 
2.2.2
