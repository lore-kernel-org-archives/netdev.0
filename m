From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 01/24] igb: Add anti-spoofing feature documentation
Date: Wed, 13 Apr 2011 18:01:57 -0700
Message-ID: <1302742940-22141-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64021 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102Ab1DNBC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:27 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add the documentation for the anti-spoofing feature in the HW.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/igb.txt |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
index 98953c0..9a2a037 100644
--- a/Documentation/networking/igb.txt
+++ b/Documentation/networking/igb.txt
@@ -93,6 +93,19 @@ Additional Configurations
   REQUIREMENTS: MSI-X support is required for Multiqueue. If MSI-X is not
   found, the system will fallback to MSI or to Legacy interrupts.
 
+  MAC and VLAN anti-spoofing feature
+  ----------------------------------
+  When a malicious driver attempts to send a spoofed packet, it is dropped by
+  the hardware and not transmitted.  An interrupt is sent to the PF driver
+  notifying it of the spoof attempt.
+
+  When a spoofed packet is detected the PF driver will send the following
+  message to the system log (displayed by  the "dmesg" command):
+
+  Spoof event(s) detected on VF(n)
+
+  Where n=the VF that attempted to do the spoofing.
+
 Support
 =======
 
-- 
1.7.4.2

