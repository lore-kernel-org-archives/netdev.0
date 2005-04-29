From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 11/11] ixgb: Driver version, white
 space, comments, device id
Date: Thu, 28 Apr 2005 19:05:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281901520.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Driver version, white space, comments, device id & other

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-04-05 23:06:38.283932752 -0700
@@ -47,7 +47,7 @@ char ixgb_driver_string[] = "Intel(R) PR
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char ixgb_driver_version[] = "1.0.90-k2"DRIVERNAPI;
+char ixgb_driver_version[] = "1.0.95-k2"DRIVERNAPI;
 char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
@@ -103,6 +103,7 @@ static int ixgb_change_mtu(struct net_de
 static int ixgb_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
+
 #ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct net_device *netdev, int *budget);
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
@@ -1253,6 +1254,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
+
 	len -= skb->data_len;
 
 	i = tx_ring->next_to_use;
@@ -1857,7 +1833,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		next_skb = next_buffer->skb;
 		prefetch(next_skb);
 
-
 		cleaned = TRUE;
 
 		pci_unmap_single(pdev,
@@ -2108,6 +2095,7 @@ ixgb_restore_vlan(struct ixgb_adapter *a
 static void ixgb_netpoll(struct net_device *dev)
 {
 	struct ixgb_adapter *adapter = dev->priv;
+
 	disable_irq(adapter->pdev->irq);
 	ixgb_intr(adapter->pdev->irq, dev, NULL);
 	enable_irq(adapter->pdev->irq);
