From: sfeldma@gmail.com
Subject: [PATCH net-next 1/4] switchdev: documentation: fix longer-than-80-char lines
Date: Wed,  3 Jun 2015 20:43:40 -0700
Message-ID: <1433389423-58467-2-git-send-email-sfeldma@gmail.com>
References: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36742 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbFDDlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:41:45 -0400
Received: by pdjm12 with SMTP id m12so21252974pdj.3
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 20:41:44 -0700 (PDT)
In-Reply-To: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |   36 ++++++++++++++++----------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 616f892..5061d6e 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -114,11 +114,11 @@ would be sub-port 0 on port 1 on switch 1.
 Switch ID
 ^^^^^^^^^
 
-The switchdev driver must implement the switchdev op switchdev_port_attr_get for
-SWITCHDEV_ATTR_PORT_PARENT_ID for each port netdev, returning the same physical ID
-for each port of a switch.  The ID must be unique between switches on the same
-system.  The ID does not need to be unique between switches on different
-systems.
+The switchdev driver must implement the switchdev op switchdev_port_attr_get
+for SWITCHDEV_ATTR_PORT_PARENT_ID for each port netdev, returning the same
+physical ID for each port of a switch.  The ID must be unique between switches
+on the same system.  The ID does not need to be unique between switches on
+different systems.
 
 The switch ID is used to locate ports on a switch and to know if aggregated
 ports belong to the same switch.
@@ -194,11 +194,11 @@ in turn, will notify the bridge driver using the switchdev notifier call:
 
 	err = call_switchdev_notifiers(val, dev, info);
 
-Where val is SWITCHDEV_FDB_ADD when learning and SWITCHDEV_FDB_DEL when forgetting, and
-info points to a struct switchdev_notifier_fdb_info.  On SWITCHDEV_FDB_ADD, the bridge
-driver will install the FDB entry into the bridge's FDB and mark the entry as
-NTF_EXT_LEARNED.  The iproute2 bridge command will label these entries
-"offload":
+Where val is SWITCHDEV_FDB_ADD when learning and SWITCHDEV_FDB_DEL when
+forgetting, and info points to a struct switchdev_notifier_fdb_info.  On
+SWITCHDEV_FDB_ADD, the bridge driver will install the FDB entry into the
+bridge's FDB and mark the entry as NTF_EXT_LEARNED.  The iproute2 bridge
+command will label these entries "offload":
 
 	$ bridge fdb
 	52:54:00:12:35:01 dev sw1p1 master br0 permanent
@@ -229,18 +229,18 @@ the bridge's FDB.  It's possible, but not optimal, to enable learning on the
 device port and on the bridge port, and disable learning_sync.
 
 To support learning and learning_sync port attributes, the driver implements
-switchdev op switchdev_port_attr_get/set for SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS.  The driver
-should initialize the attributes to the hardware defaults.
+switchdev op switchdev_port_attr_get/set for SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS.
+The driver should initialize the attributes to the hardware defaults.
 
 FDB Ageing
 ^^^^^^^^^^
 
 There are two FDB ageing models supported: 1) ageing by the device, and 2)
 ageing by the kernel.  Ageing by the device is preferred if many FDB entries
-are supported.  The driver calls call_switchdev_notifiers(SWITCHDEV_FDB_DEL, ...) to
-age out the FDB entry.  In this model, ageing by the kernel should be turned
-off.  XXX: how to turn off ageing in kernel on a per-port basis or otherwise
-prevent the kernel from ageing out the FDB entry?
+are supported.  The driver calls call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
+...) to age out the FDB entry.  In this model, ageing by the kernel should be
+turned off.  XXX: how to turn off ageing in kernel on a per-port basis or
+otherwise prevent the kernel from ageing out the FDB entry?
 
 In the kernel ageing model, the standard bridge ageing mechanism is used to age
 out stale FDB entries.  To keep an FDB entry "alive", the driver should refresh
@@ -262,8 +262,8 @@ STP State Change on Port
 
 Internally or with a third-party STP protocol implementation (e.g. mstpd), the
 bridge driver maintains the STP state for ports, and will notify the switch
-driver of STP state change on a port using the switchdev op switchdev_attr_port_set for
-SWITCHDEV_ATTR_PORT_STP_UPDATE.
+driver of STP state change on a port using the switchdev op
+switchdev_attr_port_set for SWITCHDEV_ATTR_PORT_STP_UPDATE.
 
 State is one of BR_STATE_*.  The switch driver can use STP state updates to
 update ingress packet filter list for the port.  For example, if port is
-- 
1.7.10.4
