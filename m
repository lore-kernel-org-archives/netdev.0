From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] ixgbe: fix documentation
Date: Fri, 10 Apr 2015 00:53:11 -0700
Message-ID: <1428652398-10147-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55251 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240AbbDJHxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:21 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

The MTU values in the documentation do not match the source.
The source has frame limit of IXGBE_MAX_JUMBO_FRAME_SIZE (9728)
which is MTU of 9710 because of the accounting for Ethernet header
and CRC.

Also, don't refer to the obsolete ifconfig command.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/ixgbe.txt | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
index 0ace6e7..6f0cb57 100644
--- a/Documentation/networking/ixgbe.txt
+++ b/Documentation/networking/ixgbe.txt
@@ -70,10 +70,10 @@ Avago      1000BASE-T SFP                                    ABCU-5710RZ
 82599-based adapters support all passive and active limiting direct attach
 cables that comply with SFF-8431 v4.1 and SFF-8472 v10.4 specifications.
 
-Laser turns off for SFP+ when ifconfig down
+Laser turns off for SFP+ when device is down
 -------------------------------------------
-"ifconfig down" turns off the laser for 82599-based SFP+ fiber adapters.
-"ifconfig up" turns on the laser.
+"ip link set down" turns off the laser for 82599-based SFP+ fiber adapters.
+"ip link set up" turns on the laser.
 
 
 82598-BASED ADAPTERS
@@ -213,13 +213,13 @@ Additional Configurations
   ------------
   The driver supports Jumbo Frames for all adapters. Jumbo Frames support is
   enabled by changing the MTU to a value larger than the default of 1500.
-  The maximum value for the MTU is 16110.  Use the ifconfig command to
+  The maximum value for the MTU is 16110.  Use the ip command to
   increase the MTU size.  For example:
 
-        ifconfig ethx mtu 9000 up
+        ip link set dev ethx mtu 9000
 
-  The maximum MTU setting for Jumbo Frames is 16110.  This value coincides
-  with the maximum Jumbo Frames size of 16128.
+  The maximum MTU setting for Jumbo Frames is 9710.  This value coincides
+  with the maximum Jumbo Frames size of 9728.
 
   Generic Receive Offload, aka GRO
   --------------------------------
-- 
1.9.3
