From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 03/27] Documentation/networking/igb.txt: update documentation
Date: Fri, 10 Dec 2010 22:16:57 -0800
Message-ID: <1292048241-22026-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:49712
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751207Ab0LKGRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:17:48 -0500
To: davem@davemloft.net
In-Reply-To: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Intel Wired LAN igb documentation.

v2- Updated the ethtool support link, removed the LRO section and
    anti-spoofing sections.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/igb.txt |   31 ++++---------------------------
 1 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
index ab2d718..4a5e29c 100644
--- a/Documentation/networking/igb.txt
+++ b/Documentation/networking/igb.txt
@@ -36,6 +36,7 @@ Default Value: 0
 This parameter adds support for SR-IOV.  It causes the driver to spawn up to
 max_vfs worth of virtual function.
 
+
 Additional Configurations
 =========================
 
@@ -60,9 +61,10 @@ Additional Configurations
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.
+  diagnostics, as well as displaying statistical information. The latest
+  version of Ethtool can be found at:
 
-  http://sourceforge.net/projects/gkernel.
+  http://ftp.kernel.org/pub/software/network/ethtool/
 
   Enabling Wake on LAN* (WoL)
   ---------------------------
@@ -91,31 +93,6 @@ Additional Configurations
   REQUIREMENTS: MSI-X support is required for Multiqueue. If MSI-X is not
   found, the system will fallback to MSI or to Legacy interrupts.
 
-  LRO
-  ---
-  Large Receive Offload (LRO) is a technique for increasing inbound throughput
-  of high-bandwidth network connections by reducing CPU overhead. It works by
-  aggregating multiple incoming packets from a single stream into a larger
-  buffer before they are passed higher up the networking stack, thus reducing
-  the number of packets that have to be processed. LRO combines multiple
-  Ethernet frames into a single receive in the stack, thereby potentially
-  decreasing CPU utilization for receives.
-
-  NOTE: You need to have inet_lro enabled via either the CONFIG_INET_LRO or
-  CONFIG_INET_LRO_MODULE kernel config option. Additionally, if
-  CONFIG_INET_LRO_MODULE is used, the inet_lro module needs to be loaded
-  before the igb driver.
-
-  You can verify that the driver is using LRO by looking at these counters in
-  Ethtool:
-
-  lro_aggregated - count of total packets that were combined
-  lro_flushed - counts the number of packets flushed out of LRO
-  lro_no_desc - counts the number of times an LRO descriptor was not available
-  for the LRO packet
-
-  NOTE: IPv6 and UDP are not supported by LRO.
-
 Support
 =======
 
-- 
1.7.3.2

