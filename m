From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH 2.5 2/2] 10GbE ethtool support
Date: Thu, 29 May 2003 22:12:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0305292208020.29745-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Feldman, Scott" <scott.feldman@intel.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add 10GbE support for ethtool.

--- linux-2.5/include/linux/ethtool.h.orig	2003-05-29 21:55:28.000000000 -0700
+++ linux-2.5/include/linux/ethtool.h	2003-05-29 21:56:30.000000000 -0700
@@ -299,6 +299,7 @@
 #define SUPPORTED_MII			(1 << 9)
 #define SUPPORTED_FIBRE			(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
+#define SUPPORTED_10000baseT_Full	(1 << 12)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -313,6 +314,7 @@
 #define ADVERTISED_MII			(1 << 9)
 #define ADVERTISED_FIBRE		(1 << 10)
 #define ADVERTISED_BNC			(1 << 11)
+#define ADVERTISED_10000baseT_Full	(1 << 12)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -320,10 +322,11 @@
  * it was foced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit. */
+/* The forced speed, 10Mb, 100Mb, gigabit, 10GbE. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
+#define SPEED_10000		10000
 
 /* Duplex, half or full. */
 #define DUPLEX_HALF		0x00
