From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mark arcnet_setup static
Date: Sun, 24 Oct 2004 15:20:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024132051.GB19867@lst.de>
References: <20041024131823.GC19658@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20041024131823.GC19658@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

also needs a header update, sorry:

--- 1.7/include/linux/arcdevice.h	2004-10-05 22:16:18 +02:00
+++ edited/include/linux/arcdevice.h	2004-10-23 16:09:24 +02:00
@@ -330,7 +330,6 @@
 
 void arcnet_unregister_proto(struct ArcProto *proto);
 irqreturn_t arcnet_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-void arcdev_setup(struct net_device *dev);
 struct net_device *alloc_arcdev(char *name);
 void arcnet_rx(struct net_device *dev, int bufnum);
 
