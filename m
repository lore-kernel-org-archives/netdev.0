From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 10/16 2.5] ixgb: shrink size of ixgb_buffer (use uint16_t
 for length/next_to_watch)
Date: Fri, 15 Oct 2004 06:55:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150635370.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-05 16:03:24.000000000 -0700
@@ -105,9 +105,9 @@ struct ixgb_adapter;
 struct ixgb_buffer {
 	struct sk_buff *skb;
 	uint64_t dma;
-	unsigned long length;
+	uint16_t length;
 	unsigned long time_stamp;
-	unsigned int next_to_watch;
+	uint16_t next_to_watch;
 };
 
 struct ixgb_desc_ring {
