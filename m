From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] bridge.8: minor formatting cleanup
Date: Tue, 24 Nov 2015 15:50:00 +0100
Message-ID: <1448376600-15210-1-git-send-email-phil@nwl.cc>
References: <20151123155731.3e882df2@xeon-e3>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57467 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502AbbKXOuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 09:50:13 -0500
In-Reply-To: <20151123155731.3e882df2@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Replace commas at end of subsection with dots.
- Replace double whitespace by single one.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Resolved conflict with current master.
- All whitespace at EOL already gone, adjusted commit message.
---
 man/man8/bridge.8 | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 98a92eb..0ec6f17 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -25,14 +25,14 @@ bridge \- show / manipulate bridge addresses and devices
 
 .ti -8
 .BR "bridge link set"
-.B  dev
+.B dev
 .IR DEV
 .IR " [ "
-.B  cost
+.B cost
 .IR COST " ] [ "
-.B  priority
-.IR PRIO " ]  [ "
-.B  state
+.B priority
+.IR PRIO " ] [ "
+.B state
 .IR STATE "] ["
 .BR guard " { " on " | " off " } ] [ "
 .BR hairpin " { " on " | " off " } ] [ "
@@ -42,21 +42,21 @@ bridge \- show / manipulate bridge addresses and devices
 .BR learning_sync " { " on " | " off " } ] [ "
 .BR flood " { " on " | " off " } ] [ "
 .BR hwmode " { " vepa " | " veb " } ] [ "
-.BR self " ]  [ " master " ] "
+.BR self " ] [ " master " ] "
 
 .ti -8
 .BR "bridge link" " [ " show " ] [ "
-.B  dev
+.B dev
 .IR DEV " ]"
 
 .ti -8
 .BR "bridge fdb" " { " add " | " append " | " del " | " replace " } "
 .I LLADDR
-.B  dev
+.B dev
 .IR DEV " { "
 .BR local " | " temp " } [ "
 .BR self " ] [ " master " ] [ " router " ] [ " use " ] [ "
-.B  dst
+.B dst
 .IR IPADDR " ] [ "
 .B vni
 .IR VNI " ] ["
@@ -67,12 +67,12 @@ bridge \- show / manipulate bridge addresses and devices
 
 .ti -8
 .BR "bridge fdb" " [ " show " ] [ "
-.B  dev
+.B dev
 .IR DEV " ]"
 
 .ti -8
 .BR "bridge mdb" " { " add " | " del " } "
-.B  dev
+.B dev
 .IR DEV
 .B port
 .IR PORT
@@ -84,21 +84,21 @@ bridge \- show / manipulate bridge addresses and devices
 
 .ti -8
 .BR "bridge mdb show " [ "
-.B  dev
+.B dev
 .IR DEV " ]"
 
 .ti -8
 .BR "bridge vlan" " { " add " | " del " } "
-.B  dev
+.B dev
 .IR DEV
-.B  vid
+.B vid
 .IR VID " [ "
-.BR  pvid " ] [ " untagged " ]  [ "
-.BR  self " ]  [ " master " ] "
+.BR pvid " ] [ " untagged " ] [ "
+.BR self " ] [ " master " ] "
 
 .ti -8
 .BR "bridge vlan" " [ " show " ] [ "
-.B  dev
+.B dev
 .IR DEV " ]"
 
 .ti -8
@@ -319,7 +319,7 @@ This command displays the current bridge port configuration and flags.
 .SH bridge fdb - forwarding database management
 
 .B fdb
-objects contain known Ethernet addresses on a  link.
+objects contain known Ethernet addresses on a link.
 
 .P
 The corresponding commands display fdb entries, add new entries,
@@ -398,21 +398,21 @@ sends a copy of the data packet to each entry found.
 
 .PP
 The arguments are the same as with
-.BR "bridge fdb add" ,
+.BR "bridge fdb add" .
 
 .SS bridge fdb delete - delete a forwarding database entry
 This command removes an existing fdb entry.
 
 .PP
 The arguments are the same as with
-.BR "bridge fdb add" ,
+.BR "bridge fdb add" .
 
 .SS bridge fdb replace - replace a forwarding database entry
 If no matching entry is found, a new one will be created instead.
 
 .PP
 The arguments are the same as with
-.BR "bridge fdb add" ,
+.BR "bridge fdb add" .
 
 .SS bridge fdb show - list forwarding entries.
 
@@ -548,7 +548,7 @@ This command displays the current VLAN filter table.
 
 The
 .B bridge
-utility can monitor the state of devices and  addresses
+utility can monitor the state of devices and addresses
 continuously. This option has a slightly different format.
 Namely, the
 .B monitor
@@ -560,7 +560,7 @@ command is the first in the command line and then the object list follows:
 .I OBJECT-LIST
 is the list of object types that we want to monitor.
 It may contain
-.BR link ",  " fdb ", and " mdb "."
+.BR link ", " fdb ", and " mdb "."
 If no
 .B file
 argument is given,
-- 
2.5.0
