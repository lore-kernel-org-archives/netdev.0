From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 5/10] ixgb: Limit Rx Address Filter Array entries
 to 3
Date: Fri, 29 Oct 2004 05:10:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290454500.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb_hw.h netdev-2.6/drivers/net/ixgb.new/ixgb_hw.h
--- netdev-2.6/drivers/net/ixgb/ixgb_hw.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_hw.h	2004-10-15 13:15:53.000000000 -0700
@@ -616,9 +616,9 @@ struct ixgb_context_desc {
 #define IXGB_CONTEXT_DESC_STATUS_DD 0x01
 
 /* Filters */
-#define IXGB_RAR_ENTRIES          16	/* Number of entries in Rx Address array */
 #define IXGB_MC_TBL_SIZE          128	/* Multicast Filter Table (4096 bits) */
 #define IXGB_VLAN_FILTER_TBL_SIZE 128	/* VLAN Filter Table (4096 bits) */
+#define IXGB_RAR_ENTRIES	   3	/* Number of entries in Rx Address array */
 
 #define IXGB_MEMORY_REGISTER_BASE_ADDRESS   0
 #define ENET_HEADER_SIZE            14
