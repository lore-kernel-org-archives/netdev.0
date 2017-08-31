From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] net: fix two typos in net_device_ops documentation.
Date: Thu, 31 Aug 2017 13:41:40 +0300
Message-ID: <1504176100-28914-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44618 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750757AbdHaKlp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 06:41:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two trivial typos in net_device_ops documentation,
related to ndo_xdp_flush callback.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 29bf06f..35de831 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1124,8 +1124,8 @@ struct xfrmdev_ops {
  *	This function is used to submit a XDP packet for transmit on a
  *	netdevice.
  * void (*ndo_xdp_flush)(struct net_device *dev);
- *	This function is used to inform the driver to flush a paticular
- *	xpd tx queue. Must be called on same CPU as xdp_xmit.
+ *	This function is used to inform the driver to flush a particular
+ *	xdp tx queue. Must be called on same CPU as xdp_xmit.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
-- 
1.9.1
