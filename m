From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: fix indentation
Date: Sun, 23 Nov 2008 14:43:25 +0100
Message-ID: <49295DFD.9050609@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:54859 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758027AbYKWOPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 09:15:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bring the indentation in line with the output of the Lindent script.

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge.c	2008-11-23 14:35:01.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-11-23 11:57:24.000000000 +0100
@@ -1024,7 +1024,7 @@
 			ss->dca_tag = NULL;
 		}
 	}
-#endif				/* CONFIG_MYRI10GE_DCA */
+#endif /* CONFIG_MYRI10GE_DCA */
 
 	/* reset mcp/driver shared state back to 0 */
 
@@ -1121,7 +1121,7 @@
 		myri10ge_teardown_dca(mgp);
 	return 0;
 }
-#endif				/* CONFIG_MYRI10GE_DCA */
+#endif /* CONFIG_MYRI10GE_DCA */
 
 static inline void
 myri10ge_submit_8rx(struct mcp_kreq_ether_recv __iomem * dst,
@@ -3370,7 +3370,7 @@
 	return -EIO;
 
 }
-#endif				/* CONFIG_PM */
+#endif /* CONFIG_PM */
 
 static u32 myri10ge_read_reboot(struct myri10ge_priv *mgp)
 {
@@ -3732,14 +3732,14 @@
 }
 
 static const struct net_device_ops myri10ge_netdev_ops = {
-	.ndo_open		= myri10ge_open,
-	.ndo_stop		= myri10ge_close,
-	.ndo_start_xmit		= myri10ge_xmit,
-	.ndo_get_stats		= myri10ge_get_stats,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= myri10ge_change_mtu,
+	.ndo_open = myri10ge_open,
+	.ndo_stop = myri10ge_close,
+	.ndo_start_xmit = myri10ge_xmit,
+	.ndo_get_stats = myri10ge_get_stats,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_change_mtu = myri10ge_change_mtu,
 	.ndo_set_multicast_list = myri10ge_set_multicast_list,
-	.ndo_set_mac_address	= myri10ge_set_mac_address,
+	.ndo_set_mac_address = myri10ge_set_mac_address,
 };
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -4027,7 +4027,7 @@
 	.next = NULL,
 	.priority = 0,
 };
-#endif				/* CONFIG_MYRI10GE_DCA */
+#endif /* CONFIG_MYRI10GE_DCA */
 
 static __init int myri10ge_init_module(void)
 {
--- net-next-2.6/drivers/net/myri10ge/myri10ge_mcp.h	2008-10-29 10:25:24.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge_mcp.h	2008-11-23 11:57:24.000000000 +0100
@@ -423,4 +423,4 @@
 #define MXGEFW_NETQ_FILTERTYPE_VLAN 2
 #define MXGEFW_NETQ_FILTERTYPE_VLANMACADDR 3
 
-#endif				/* __MYRI10GE_MCP_H__ */
+#endif /* __MYRI10GE_MCP_H__ */
diff -ur net-next-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h /home/bgoglin/myri10ge/myri10ge-cvs/linux/linux-tmp/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
--- net-next-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-11-23 14:36:02.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-11-23 11:57:24.000000000 +0100
@@ -45,4 +45,4 @@
 	/* 8 */
 };
 
-#endif				/* __MYRI10GE_MCP_GEN_HEADER_H__ */
+#endif /* __MYRI10GE_MCP_GEN_HEADER_H__ */


