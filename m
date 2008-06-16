From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/3] netdevice: change net_device->promiscuity/allmulti to
 unsigned int
Date: Mon, 16 Jun 2008 17:14:53 +0800
Message-ID: <48562F0D.1090107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54617 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757101AbYFPJSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:18:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comments of dev_set_allmulti/promiscuity() is that "While the count in
the device remains above zero...". So negative count is useless.
Fix the type of the counter from "int" to "unsigned int".

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/linux/netdevice.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f27fd20..06d8ea5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -595,8 +595,8 @@ struct net_device
 	int			uc_promisc;
 	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
 	int			mc_count;	/* Number of installed mcasts	*/
-	int			promiscuity;
-	int			allmulti;
+	unsigned int		promiscuity;
+	unsigned int		allmulti;
 
 
 	/* Protocol specific pointers */
-- 
1.5.3.4


