From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 5/9] ixgb: Fix ordering of elements in ixgb_buffer to
 avoid padding by the compiler.
Date: Thu, 6 Jan 2005 17:22:33 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061550240.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2005-01-05 17:13:28.000000000 -0800
@@ -120,8 +120,8 @@ struct ixgb_adapter;
 struct ixgb_buffer {
 	struct sk_buff *skb;
 	uint64_t dma;
-	uint16_t length;
 	unsigned long time_stamp;
+	uint16_t length;
 	uint16_t next_to_watch;
 };
 
