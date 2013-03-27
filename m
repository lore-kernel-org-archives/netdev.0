From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] line up comment for ndo_bridge_getlink
Date: Wed, 27 Mar 2013 18:54:00 +0200
Message-ID: <1364403241-9061-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3408 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705Ab3C0QyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 12:54:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 56e3e06..f2bc873 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -895,7 +895,7 @@ struct netdev_fcoe_hbainfo {
  *
  * int (*ndo_bridge_setlink)(struct net_device *dev, struct nlmsghdr *nlh)
  * int (*ndo_bridge_getlink)(struct sk_buff *skb, u32 pid, u32 seq,
- *			     struct net_device *dev)
+ *			     struct net_device *dev, u32 filter_mask)
  *
  * int (*ndo_change_carrier)(struct net_device *dev, bool new_carrier);
  *	Called to change device carrier. Soft-devices (like dummy, team, etc)
-- 
1.7.7.2
