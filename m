From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 4/13] e1000: Enabling NETIF_F_SG without checksum offload
 is illegal -- jdmason@us.ibm.com
Date: Thu, 6 Jan 2005 17:09:22 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061502390.7330-100000@isotope.jf.intel.com>
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
@@ -475,8 +475,6 @@ e1000_probe(struct pci_dev *pdev,
 				   NETIF_F_HW_VLAN_TX |
 				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
-	} else {
-		netdev->features = NETIF_F_SG;
 	}
 
 #ifdef NETIF_F_TSO
