From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] igb: doc don't refer to ifconfig
Date: Fri, 10 Apr 2015 00:53:10 -0700
Message-ID: <1428652398-10147-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9700 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232AbbDJHxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:20 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

ifconfig command is obsolete, best to remove all references so that
new users learn ip.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/igb.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
index 43d3549..15534fd 100644
--- a/Documentation/networking/igb.txt
+++ b/Documentation/networking/igb.txt
@@ -42,10 +42,10 @@ Additional Configurations
   Jumbo Frames
   ------------
   Jumbo Frames support is enabled by changing the MTU to a value larger than
-  the default of 1500.  Use the ifconfig command to increase the MTU size.
+  the default of 1500.  Use the ip command to increase the MTU size.
   For example:
 
-       ifconfig eth<x> mtu 9000 up
+       ip link set dev eth<x> mtu 9000
 
   This setting is not saved across reboots.
 
-- 
1.9.3
