From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 5/6] collision retry count too high
Date: Sat, 21 Feb 2004 23:34:49 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212325400.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* For half duplex, the IEEE says collision retry count should
  be 15 not 16.  Would cause really slow transfers on some hubs
  (i.e NetGear DS108).

----------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_hw.h netdev-2.6/drivers/net/e1000.mod/e1000_hw.h
--- netdev-2.6/drivers/net/e1000/e1000_hw.h	2004-02-20 14:07:57.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_hw.h	2004-02-20 14:08:39.000000000 -0800
@@ -1540,7 +1540,7 @@ struct e1000_hw {
 #define PBA_SIZE 4
 
 /* Collision related configuration parameters */
-#define E1000_COLLISION_THRESHOLD       16
+#define E1000_COLLISION_THRESHOLD       15
 #define E1000_CT_SHIFT                  4
 #define E1000_COLLISION_DISTANCE        64
 #define E1000_FDX_COLLISION_DISTANCE    E1000_COLLISION_DISTANCE
