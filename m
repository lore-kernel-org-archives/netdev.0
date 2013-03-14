From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1@lab.ntt.co.jp>
Subject: net: clean leftover of COMPAT_NET_DEV_OPS removal
Date: Thu, 14 Mar 2013 11:57:25 +0900
Message-ID: <1363229845.5774.2.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:53794 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab3CNEE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 00:04:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

COMPAT_NET_DEV_OPS was removed a while back and with it the definition of
netdev_resync_ops() went away. Let's finish the clean-up.

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-3.9-rc2-orig/include/linux/netdevice.h linux-3.9-rc2/include/linux/netdevice.h
--- linux-3.9-rc2-orig/include/linux/netdevice.h	2013-03-11 08:54:19.000000000 +0900
+++ linux-3.9-rc2/include/linux/netdevice.h	2013-03-14 11:45:58.686715874 +0900
@@ -1684,7 +1684,6 @@ extern int 		netdev_refcnt_read(const st
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int		init_dummy_netdev(struct net_device *dev);
-extern void		netdev_resync_ops(struct net_device *dev);
 
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
