From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] remove iph5526 driver
Date: Mon, 6 Sep 2004 19:22:55 +0200
Sender: linux-scsi-owner@vger.kernel.org
Message-ID: <20040906172255.GA24194@lst.de>
References: <20040906101014.GA17597@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-scsi-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-scsi@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20040906101014.GA17597@lst.de>
List-Id: netdev.vger.kernel.org

On Mon, Sep 06, 2004 at 12:10:14PM +0200, Christoph Hellwig wrote:
> This driver is for totally obsolete early fibrechannel hardware and
> doesn't compile anymore since early 2.5.x.  In addition it'll require
> a major rewrite to fit into the current framework for fc drivers.

In addition this makefile fixup is needed to build with CONFIG_NET_FC:

--- 1.86/drivers/net/Makefile	2004-08-22 22:57:31 +02:00
+++ edited/drivers/net/Makefile	2004-09-06 19:06:10 +02:00
@@ -184,7 +184,6 @@
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
 
 obj-$(CONFIG_ARM) += arm/
-obj-$(CONFIG_NET_FC) += fc/
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
