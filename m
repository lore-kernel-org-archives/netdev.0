From: Qinghuang Feng <qhfeng.kernel@gmail.com>
Subject: [PATCH 2/3] drivers/net/chelsio/sge.c: remove redundant argument
 comments
Date: Sat, 22 Nov 2008 15:41:03 +0800
Message-ID: <4927b79c.08486e0a.6977.048a@mx.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:2438 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbYKVHlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:41:18 -0500
Received: by ti-out-0910.google.com with SMTP id b6so794718tic.23
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 23:41:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove redundant argument comments

Signed-off-by: Qinghuang Feng <qhfeng.kernel@gmail.com>
---
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index d6c7d2a..7092df5 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1035,10 +1035,6 @@ MODULE_PARM_DESC(copybreak, "Receive copy threshold");
  *	@pdev: the PCI device that received the packet
  *	@fl: the SGE free list holding the packet
  *	@len: the actual packet length, excluding any SGE padding
- *	@dma_pad: padding at beginning of buffer left by SGE DMA
- *	@skb_pad: padding to be used if the packet is copied
- *	@copy_thres: length threshold under which a packet should be copied
- *	@drop_thres: # of remaining buffers before we start dropping packets
  *
  *	Get the next packet from a free list and complete setup of the
  *	sk_buff.  If the packet is small we make a copy and recycle the

