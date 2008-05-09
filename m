From: Brice Goglin <brice@myri.com>
Subject: [PATCH 02/16] myri10ge: fix module parameter descriptions
Date: Fri, 09 May 2008 02:16:53 +0200
Message-ID: <482397F5.30802@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933837AbYEIAqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:22 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless linebreaks at the end of MODULE_PARM_DESC
and fix the description of myri10ge_lro_max_pkts.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-08 23:59:52.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:00:45.000000000 +0200
@@ -228,58 +228,58 @@
 
 static char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name\n");
+MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name");
 
 static int myri10ge_ecrc_enable = 1;
 module_param(myri10ge_ecrc_enable, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_ecrc_enable, "Enable Extended CRC on PCI-E\n");
+MODULE_PARM_DESC(myri10ge_ecrc_enable, "Enable Extended CRC on PCI-E");
 
 static int myri10ge_max_intr_slots = 1024;
 module_param(myri10ge_max_intr_slots, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_max_intr_slots, "Interrupt queue slots\n");
+MODULE_PARM_DESC(myri10ge_max_intr_slots, "Interrupt queue slots");
 
 static int myri10ge_small_bytes = -1;	/* -1 == auto */
 module_param(myri10ge_small_bytes, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_small_bytes, "Threshold of small packets\n");
+MODULE_PARM_DESC(myri10ge_small_bytes, "Threshold of small packets");
 
 static int myri10ge_msi = 1;	/* enable msi by default */
 module_param(myri10ge_msi, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts\n");
+MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts");
 
 static int myri10ge_intr_coal_delay = 75;
 module_param(myri10ge_intr_coal_delay, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay\n");
+MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay");
 
 static int myri10ge_flow_control = 1;
 module_param(myri10ge_flow_control, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_flow_control, "Pause parameter\n");
+MODULE_PARM_DESC(myri10ge_flow_control, "Pause parameter");
 
 static int myri10ge_deassert_wait = 1;
 module_param(myri10ge_deassert_wait, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_deassert_wait,
-		 "Wait when deasserting legacy interrupts\n");
+		 "Wait when deasserting legacy interrupts");
 
 static int myri10ge_force_firmware = 0;
 module_param(myri10ge_force_firmware, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_force_firmware,
-		 "Force firmware to assume aligned completions\n");
+		 "Force firmware to assume aligned completions");
 
 static int myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
 module_param(myri10ge_initial_mtu, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_initial_mtu, "Initial MTU\n");
+MODULE_PARM_DESC(myri10ge_initial_mtu, "Initial MTU");
 
 static int myri10ge_napi_weight = 64;
 module_param(myri10ge_napi_weight, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_napi_weight, "Set NAPI weight\n");
+MODULE_PARM_DESC(myri10ge_napi_weight, "Set NAPI weight");
 
 static int myri10ge_watchdog_timeout = 1;
 module_param(myri10ge_watchdog_timeout, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_watchdog_timeout, "Set watchdog timeout\n");
+MODULE_PARM_DESC(myri10ge_watchdog_timeout, "Set watchdog timeout");
 
 static int myri10ge_max_irq_loops = 1048576;
 module_param(myri10ge_max_irq_loops, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_max_irq_loops,
-		 "Set stuck legacy IRQ detection threshold\n");
+		 "Set stuck legacy IRQ detection threshold");
 
 #define MYRI10GE_MSG_DEFAULT NETIF_MSG_LINK
 
@@ -289,21 +289,22 @@
 
 static int myri10ge_lro = 1;
 module_param(myri10ge_lro, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_lro, "Enable large receive offload\n");
+MODULE_PARM_DESC(myri10ge_lro, "Enable large receive offload");
 
 static int myri10ge_lro_max_pkts = MYRI10GE_LRO_MAX_PKTS;
 module_param(myri10ge_lro_max_pkts, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_lro, "Number of LRO packets to be aggregated\n");
+MODULE_PARM_DESC(myri10ge_lro_max_pkts,
+		 "Number of LRO packets to be aggregated");
 
 static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
+MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed");
 
 static int myri10ge_reset_recover = 1;
 
 static int myri10ge_wcfifo = 0;
 module_param(myri10ge_wcfifo, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
+MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled");
 
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \


