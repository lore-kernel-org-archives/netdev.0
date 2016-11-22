From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] netdevice.h: fix kernel-doc warning
Date: Mon, 21 Nov 2016 18:28:36 -0800
Message-ID: <89f2d6da-89e1-1962-9f6f-e81dece8a101@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50422 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754175AbcKVC2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 21:28:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warning in <linux/netdevice.h> (missing ':'):

..//include/linux/netdevice.h:1904: warning: No description found for parameter 'prio_tc_map[TC_BITMASK + 1]'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-49-rc6.orig/include/linux/netdevice.h
+++ lnx-49-rc6/include/linux/netdevice.h
@@ -1619,7 +1619,7 @@ enum netdev_priv_flags {
  *	@dcbnl_ops:	Data Center Bridging netlink ops
  *	@num_tc:	Number of traffic classes in the net device
  *	@tc_to_txq:	XXX: need comments on this one
- *	@prio_tc_map	XXX: need comments on this one
+ *	@prio_tc_map:	XXX: need comments on this one
  *
  *	@fcoe_ddp_xid:	Max exchange id for FCoE LRO by ddp
  *
