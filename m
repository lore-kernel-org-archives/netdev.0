From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 5/13] e1000: Apply patch from Jamal (hadi@znyx.com) to
 remove a redundant assignment to a local nr_frags in e1000_xmit_frame
Date: Thu, 6 Jan 2005 17:09:33 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061504130.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2004-12-06 08:43:11.635381920 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2004-12-06 08:43:12.534245272 -0800
@@ -1750,7 +1750,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int mss = 0;
 	int count = 0;
 	unsigned int f;
-	nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
 
 	if(unlikely(skb->len <= 0)) {
