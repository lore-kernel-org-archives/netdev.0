From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 1/3] net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 13:04:38 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099044278.9566.2.camel@localhost>
References: <1099044244.9566.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <1099044244.9566.0.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch introduces a generic netdev_ioaddr in include/linux/netdevice.h.
It is pulled from driver/net/natsemi.c.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---

 netdevice.h |    5 +++++
 1 files changed, 5 insertions(+)

Index: 2.6.10-rc1-mm1/include/linux/netdevice.h
===================================================================
--- 2.6.10-rc1-mm1.orig/include/linux/netdevice.h	2004-10-29 11:07:56.000000000 +0300
+++ 2.6.10-rc1-mm1/include/linux/netdevice.h	2004-10-29 11:37:56.000000000 +0300
@@ -500,6 +500,11 @@
 				& ~NETDEV_ALIGN_CONST);
 }
 
+static inline void __iomem *netdev_ioaddr(struct net_device *dev)
+{
+	return (void __iomem *) dev->base_addr;
+}
+
 #define SET_MODULE_OWNER(dev) do { } while (0)
 /* Set the sysfs physical device reference for the network logical device
  * if set prior to registration will cause a symlink during initialization.
