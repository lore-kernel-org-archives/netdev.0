From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 01/15] Documentation/networking: Update Intel Wired LAN docs
Date: Fri, 24 Dec 2010 22:06:00 -0800
Message-ID: <1293257174-15498-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:17937 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286Ab0LYGIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:08:35 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

- Update the Intel Wired LAN documentation with the latest
  URL for ethtool.

- replace "Ethtool" with "ethtool"

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
---
 Documentation/networking/e100.txt   |   19 +++++--------------
 Documentation/networking/e1000.txt  |    6 +++---
 Documentation/networking/e1000e.txt |   14 +++++++-------
 Documentation/networking/igb.txt    |    6 +++---
 Documentation/networking/igbvf.txt  |    4 ++--
 Documentation/networking/ixgb.txt   |   10 +++++-----
 Documentation/networking/ixgbe.txt  |    8 ++++----
 7 files changed, 29 insertions(+), 38 deletions(-)

diff --git a/Documentation/networking/e100.txt b/Documentation/networking/e100.txt
index 944aa55..162f323 100644
--- a/Documentation/networking/e100.txt
+++ b/Documentation/networking/e100.txt
@@ -72,7 +72,7 @@ Tx Descriptors: Number of transmit descriptors. A transmit descriptor is a data
    ethtool -G eth? tx n, where n is the number of desired tx descriptors.
 
 Speed/Duplex: The driver auto-negotiates the link speed and duplex settings by
-   default. Ethtool can be used as follows to force speed/duplex.
+   default. The ethtool utility can be used as follows to force speed/duplex.
 
    ethtool -s eth?  autoneg off speed {10|100} duplex {full|half}
 
@@ -126,30 +126,21 @@ Additional Configurations
   -------
 
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.  Ethtool
+  diagnostics, as well as displaying statistical information.  The ethtool
   version 1.6 or later is required for this functionality.
 
   The latest release of ethtool can be found from
-  http://sourceforge.net/projects/gkernel.
-
-  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Support
-  for a more complete ethtool feature set can be enabled by upgrading
-  ethtool to ethtool-1.8.1.
-
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
   Enabling Wake on LAN* (WoL)
   ---------------------------
-  WoL is provided through the Ethtool* utility. Ethtool is included with Red
-  Hat* 8.0. For other Linux distributions, download and install Ethtool from
-  the following website: http://sourceforge.net/projects/gkernel.
-
-  For instructions on enabling WoL with Ethtool, refer to the Ethtool man page.
+  WoL is provided through the ethtool* utility.  For instructions on enabling
+  WoL with ethtool, refer to the ethtool man page.
 
   WoL will be enabled on the system during the next shut down or reboot. For
   this driver version, in order to enable WoL, the e100 driver must be
   loaded when shutting down or rebooting the system.
 
-
   NAPI
   ----
 
diff --git a/Documentation/networking/e1000.txt b/Documentation/networking/e1000.txt
index 6cb13e9..71ca958 100644
--- a/Documentation/networking/e1000.txt
+++ b/Documentation/networking/e1000.txt
@@ -431,15 +431,15 @@ Additional Configurations
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.  Ethtool
+  diagnostics, as well as displaying statistical information.  The ethtool
   version 1.6 or later is required for this functionality.
 
   The latest release of ethtool can be found from
-  http://sourceforge.net/projects/gkernel.
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
   Enabling Wake on LAN* (WoL)
   ---------------------------
-  WoL is configured through the Ethtool* utility.
+  WoL is configured through the ethtool* utility.
 
   WoL will be enabled on the system during the next shut down or reboot.
   For this driver version, in order to enable WoL, the e1000 driver must be
diff --git a/Documentation/networking/e1000e.txt b/Documentation/networking/e1000e.txt
index 81a66e6..97b5ba9 100644
--- a/Documentation/networking/e1000e.txt
+++ b/Documentation/networking/e1000e.txt
@@ -269,26 +269,26 @@ Additional Configurations
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information.  We
-  strongly recommend downloading the latest version of Ethtool at:
+  strongly recommend downloading the latest version of ethtool at:
 
-  http://sourceforge.net/projects/gkernel.
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
   Speed and Duplex
   ----------------
-  Speed and Duplex are configured through the Ethtool* utility. For
-  instructions,  refer to the Ethtool man page.
+  Speed and Duplex are configured through the ethtool* utility. For
+  instructions,  refer to the ethtool man page.
 
   Enabling Wake on LAN* (WoL)
   ---------------------------
-  WoL is configured through the Ethtool* utility. For instructions on
-  enabling WoL with Ethtool, refer to the Ethtool man page.
+  WoL is configured through the ethtool* utility. For instructions on
+  enabling WoL with ethtool, refer to the ethtool man page.
 
   WoL will be enabled on the system during the next shut down or reboot.
   For this driver version, in order to enable WoL, the e1000e driver must be
   loaded when shutting down or rebooting the system.
 
   In most cases Wake On LAN is only supported on port A for multiple port
-  adapters. To verify if a port supports Wake on Lan run Ethtool eth<X>.
+  adapters. To verify if a port supports Wake on Lan run ethtool eth<X>.
 
 Support
 =======
diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
index 4a5e29c..98953c0 100644
--- a/Documentation/networking/igb.txt
+++ b/Documentation/networking/igb.txt
@@ -62,15 +62,15 @@ Additional Configurations
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information. The latest
-  version of Ethtool can be found at:
+  version of ethtool can be found at:
 
   http://ftp.kernel.org/pub/software/network/ethtool/
 
   Enabling Wake on LAN* (WoL)
   ---------------------------
-  WoL is configured through the Ethtool* utility.
+  WoL is configured through the ethtool* utility.
 
-  For instructions on enabling WoL with Ethtool, refer to the Ethtool man page.
+  For instructions on enabling WoL with ethtool, refer to the ethtool man page.
 
   WoL will be enabled on the system during the next shut down or reboot.
   For this driver version, in order to enable WoL, the igb driver must be
diff --git a/Documentation/networking/igbvf.txt b/Documentation/networking/igbvf.txt
index 694817b..cbfe4ee 100644
--- a/Documentation/networking/igbvf.txt
+++ b/Documentation/networking/igbvf.txt
@@ -58,11 +58,11 @@ Additional Configurations
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.  Ethtool
+  diagnostics, as well as displaying statistical information.  The ethtool
   version 3.0 or later is required for this functionality, although we
   strongly recommend downloading the latest version at:
 
-  http://sourceforge.net/projects/gkernel.
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
 Support
 =======
diff --git a/Documentation/networking/ixgb.txt b/Documentation/networking/ixgb.txt
index a0d0ffb..e196f16 100644
--- a/Documentation/networking/ixgb.txt
+++ b/Documentation/networking/ixgb.txt
@@ -309,15 +309,15 @@ Additional Configurations
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.  Ethtool
+  diagnostics, as well as displaying statistical information.  The ethtool
   version 1.6 or later is required for this functionality.
 
   The latest release of ethtool can be found from
-  http://sourceforge.net/projects/gkernel
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
-  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Support
-        for a more complete ethtool feature set can be enabled by upgrading
-        to the latest version.
+  NOTE: The ethtool version 1.6 only supports a limited set of ethtool options.
+        Support for a more complete ethtool feature set can be enabled by
+        upgrading to the latest version.
 
 
   NAPI
diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
index 9ade280..af77ed3 100644
--- a/Documentation/networking/ixgbe.txt
+++ b/Documentation/networking/ixgbe.txt
@@ -34,7 +34,7 @@ is an Intel(R) Ethernet Server Adapter X520-2, then it only supports Intel
 optics and/or the direct attach cables listed below.
 
 When 82599-based SFP+ devices are connected back to back, they should be set to
-the same Speed setting via Ethtool. Results may vary if you mix speed settings.
+the same Speed setting via ethtool. Results may vary if you mix speed settings.
 82598-based adapters support all passive direct attach cables that comply
 with SFF-8431 v4.1 and SFF-8472 v10.4 specifications. Active direct attach
 cables are not supported.
@@ -110,7 +110,7 @@ threshold.  When rx is enabled, the transmit unit will halt for the time delay
 specified when a PAUSE frame is received.
 
 Flow Control is enabled by default. If you want to disable a flow control
-capable link partner, use Ethtool:
+capable link partner, use ethtool:
 
      ethtool -A eth? autoneg off RX off TX off
 
@@ -181,10 +181,10 @@ Additional Configurations
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information. The latest
-  Ethtool version is required for this functionality.
+  ethtool version is required for this functionality.
 
   The latest release of ethtool can be found from
-  http://sourceforge.net/projects/gkernel.
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
   FCoE
   ----
-- 
1.7.3.4

