From: akpm@osdl.org
Subject: [patch 10/41] eexpress section fix
Date: Mon, 14 Aug 2006 23:00:01 -0700
Message-ID: <200608150600.k7F601p3012630@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59794 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965148AbWHOGBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:44 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/eexpress.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x6c3) and 'eexp_hw_lasttxstat'
WARNING: drivers/net/eexpress.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x74f) and 'eexp_hw_lasttxstat'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/eexpress.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/eexpress.c~eexpress-section-fix drivers/net/eexpress.c
--- a/drivers/net/eexpress.c~eexpress-section-fix
+++ a/drivers/net/eexpress.c
@@ -1698,7 +1698,7 @@ MODULE_LICENSE("GPL");
  * are specified, we verify and then use them.  If no parameters are given, we
  * autoprobe for one card only.
  */
-int init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
_
