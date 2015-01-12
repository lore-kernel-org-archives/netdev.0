From: B Viswanath <marichika4@gmail.com>
Subject: [PATCH] Corrected the comment describing the ndo operations to reflect the actual prototype for couple of operations
Date: Mon, 12 Jan 2015 14:46:25 +0530
Message-ID: <1421054185-10249-1-git-send-email-marichika4@gmail.com>
Cc: B Viswanath <marichika4@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:43837 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbALJQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 04:16:59 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so31030280pab.0
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 01:16:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corrected the comment describing the ndo operations to
reflect the actual prototype for couple of operations

Signed-off-by: B Viswanath <marichika4@gmail.com>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 679e6e9..7f794db 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -852,11 +852,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
- * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16t vid);
+ * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16 vid);
  *	If device support VLAN filtering this function is called when a
  *	VLAN id is registered.
  *
- * int (*ndo_vlan_rx_kill_vid)(struct net_device *dev, unsigned short vid);
+ * int (*ndo_vlan_rx_kill_vid)(struct net_device *dev, __be16 proto, u16 vid);
  *	If device support VLAN filtering this function is called when a
  *	VLAN id is unregistered.
  *
-- 
2.1.0
