From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 9/16 2.5] ixgb: limit Rx Address Filter Array entries to 3
Date: Fri, 15 Oct 2004 06:55:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150634200.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_hw.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_hw.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_hw.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_hw.h	2004-10-05 17:54:36.000000000 -0700
@@ -616,9 +616,9 @@ struct ixgb_context_desc {
 #define IXGB_CONTEXT_DESC_STATUS_DD 0x01
 
 /* Filters */
-#define IXGB_RAR_ENTRIES          16	/* Number of entries in Rx Address array */
 #define IXGB_MC_TBL_SIZE          128	/* Multicast Filter Table (4096 bits) */
 #define IXGB_VLAN_FILTER_TBL_SIZE 128	/* VLAN Filter Table (4096 bits) */
+#define IXGB_RAR_ENTRIES          3	/* Number of entries in Rx Address array */
 
 #define IXGB_MEMORY_REGISTER_BASE_ADDRESS   0
 #define ENET_HEADER_SIZE            14
