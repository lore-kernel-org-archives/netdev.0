From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 2/2 2.5] e1000 update - white space/driver version update
Date: Mon, 27 Sep 2004 09:38:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409270937490.5998-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up 
linux-2.5/drivers/net/e1000/e1000_ethtool.c 
linux-2.5/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.5/drivers/net/e1000/e1000_ethtool.c	2004-09-20 21:54:32.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_ethtool.c	2004-09-20 21:54:33.000000000 -0700
@@ -1017,8 +1017,8 @@ e1000_setup_desc_rings(struct e1000_adap
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
 		struct sk_buff *skb;
 
-		if(!(skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN,
-				     GFP_KERNEL))) {
+		if(!(skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN, 
+				GFP_KERNEL))) {
 			ret_val = 6;
 			goto err_nomem;
 		}
diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-09-20 21:54:32.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-09-20 21:54:34.000000000 -0700
@@ -48,7 +48,7 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.3.19-k2"DRIVERNAPI;
+char e1000_driver_version[] = "5.4.11-k2"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
