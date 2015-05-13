From: sfeldma@gmail.com
Subject: [PATCH net-next 4/4] switchdev: apply review comments on documentation
Date: Tue, 12 May 2015 23:03:54 -0700
Message-ID: <1431497034-22153-5-git-send-email-sfeldma@gmail.com>
References: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32970 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbbEMGCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:02:54 -0400
Received: by pacwv17 with SMTP id wv17so39889796pac.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:02:53 -0700 (PDT)
In-Reply-To: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

There were a few review comments on the switchdev.txt documentation that
didn't get included with the Spring Cleanup series, so include them now.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index b3e18c8..616f892 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -99,7 +99,7 @@ kernel pick the default netdev name, and let udev set the final name based on a
 port attribute.
 
 Using port PHYS name (ndo_get_phys_port_name) for the key is particularly
-useful for dynically-named ports where the device names it's ports based on
+useful for dynamically-named ports where the device names its ports based on
 external configuration.  For example, if a physical 40G port is split logically
 into 4 10G ports, resulting in 4 port netdevs, the device can give a unique
 name for each port using port PHYS name.  The udev rule would be:
@@ -131,7 +131,7 @@ NETIF_F_NETNS_LOCAL
 If the switchdev driver (and device) only supports offloading of the default
 network namespace (netns), the driver should set this feature flag to prevent
 the port netdev from being moved out of the default netns.  A netns-aware
-driver/device would not set this flag and be resposible for partitioning
+driver/device would not set this flag and be responsible for partitioning
 hardware to preserve netns containment.  This means hardware cannot forward
 traffic from a port in one namespace to another port in another namespace.
 
@@ -177,6 +177,9 @@ entries are installed, for example, using iproute2 bridge cmd:
 
 	bridge fdb add ADDR dev DEV [vlan VID] [self]
 
+XXX: what should be done if offloading this rule to hardware fails (for
+example, due to full capacity in hardware tables) ?
+
 Note: by default, the bridge does not filter on VLAN and only bridges untagged
 traffic.  To enable VLAN support, turn on VLAN filtering:
 
-- 
1.7.10.4
