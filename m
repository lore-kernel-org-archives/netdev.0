From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 6/10] ixgb: Shrink size of ixgb_buffer (use uint16_t
 for length/next_to_watch)
Date: Fri, 29 Oct 2004 05:11:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290456320.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb.h netdev-2.6/drivers/net/ixgb.new/ixgb.h
--- netdev-2.6/drivers/net/ixgb/ixgb.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-15 13:15:51.000000000 -0700
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
