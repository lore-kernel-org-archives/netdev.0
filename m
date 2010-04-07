From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] net: fix definition of netdev_for_each_mc_addr()
Date: Wed, 07 Apr 2010 18:01:52 -0400
Message-ID: <20100407220100.13604.6636.stgit@mj.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:17381 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756001Ab0DGWBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 18:01:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first argument should be called ha, not mclist.  All callers use the
name "ha", but if they used a different name, there would be a compile
error.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

This is against the current net-next.

 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a343a21..d1a21b5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -260,7 +260,7 @@ struct netdev_hw_addr_list {
 
 #define netdev_mc_count(dev) netdev_hw_addr_list_count(&(dev)->mc)
 #define netdev_mc_empty(dev) netdev_hw_addr_list_empty(&(dev)->mc)
-#define netdev_for_each_mc_addr(mclist, dev) \
+#define netdev_for_each_mc_addr(ha, dev) \
 	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
 struct hh_cache {
