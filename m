From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] unexport alloc_divert_blk/free_divert_blk
Date: Tue, 7 Sep 2004 17:20:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907152029.GC9735@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

these are called by dev.c for every device (and nowhere else)


--- 1.10/net/core/dv.c	2004-04-16 22:56:10 +02:00
+++ edited/net/core/dv.c	2004-09-07 15:07:09 +02:00
@@ -553,6 +553,3 @@
 		break;
 	}
 }
-
-EXPORT_SYMBOL(alloc_divert_blk);
-EXPORT_SYMBOL(free_divert_blk);
