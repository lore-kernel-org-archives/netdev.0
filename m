From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 7/8 2.5] e1000 - Ethtool -- 82545 do not support WoL
Date: Fri, 17 Sep 2004 02:58:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170237520.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_ethtool.c linux-2.5/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.5/drivers/net/e1000/e1000_ethtool.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_ethtool.c	2004-09-09 11:17:12.000000000 -0700
@@ -1442,6 +1442,8 @@ e1000_get_wol(struct net_device *netdev,
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:
 	case E1000_DEV_ID_82546EB_QUAD_COPPER:
+	case E1000_DEV_ID_82545EM_FIBER:
+	case E1000_DEV_ID_82545EM_COPPER:
 		wol->supported = 0;
 		wol->wolopts   = 0;
 		return;
