From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 8/13] e1000: {set, get}_wol is now symmetric for 82545EM
 adapters
Date: Thu, 6 Jan 2005 17:10:21 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061508320.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c	2004-12-06 08:43:11.617384656 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c	2004-12-06 08:43:12.382268376 -0800
@@ -1501,6 +1501,8 @@ e1000_set_wol(struct net_device *netdev,
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:
 	case E1000_DEV_ID_82546EB_QUAD_COPPER:
+	case E1000_DEV_ID_82545EM_FIBER:
+	case E1000_DEV_ID_82545EM_COPPER:
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
 	case E1000_DEV_ID_82546EB_FIBER:
