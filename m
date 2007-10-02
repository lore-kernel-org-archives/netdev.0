From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/1][NET] : Fix dev_put() and dev_hold() comments
Date: Tue, 02 Oct 2007 16:37:34 +0200
Message-ID: <20071002143809.936848538@frecb000701.frec.bull.fr>
References: <20071002143733.282284314@frecb000701.frec.bull.fr>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:45801 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbXJBOmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:42:00 -0400
Content-Disposition: inline; filename=Fix-dev_hold-dev_put-comments.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial fix: Swap comments for dev_put() and dev_hold() to get them 
at the right place.
Typo introduced by 4fa57c9ea9f36f9ca852f3a88ca5d2f1aebbc960.

Signed-of-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/linux/netdevice.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6.24/include/linux/netdevice.h
===================================================================
--- net-2.6.24.orig/include/linux/netdevice.h
+++ net-2.6.24/include/linux/netdevice.h
@@ -1054,7 +1054,7 @@ extern void netdev_run_todo(void);
  *	dev_put - release reference to device
  *	@dev: network device
  *
- * Hold reference to device to keep it from being freed.
+ * Release reference to device to allow it to be freed.
  */
 static inline void dev_put(struct net_device *dev)
 {
@@ -1065,7 +1065,7 @@ static inline void dev_put(struct net_de
  *	dev_hold - get reference to device
  *	@dev: network device
  *
- * Release reference to device to allow it to be freed.
+ * Hold reference to device to keep it from being freed.
  */
 static inline void dev_hold(struct net_device *dev)
 {

-- 
