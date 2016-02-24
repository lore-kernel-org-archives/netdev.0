From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 10/20] man: ip-link.8: Fix and improve synopsis
Date: Wed, 24 Feb 2016 09:21:23 +0100
Message-ID: <1456302093-697-11-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55151 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758133AbcBXIWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:48 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reflect that it is possible to pass multiple parameters at the same
time, also use the same trick the help text uses to emphasize vf
specific parameters.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 97 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 53 insertions(+), 44 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 27c9a321c2af8..cc0842f01ab59 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -92,78 +92,87 @@ ip-link \- network device configuration
 .BR "ip link set " {
 .IR DEVICE " | "
 .BI "group " GROUP
-.RB "} { " up " | " down " | " arp " { " on " | " off " } |"
+.RB "} [ { " up " | " down " } ]"
 .br
-.BR promisc " { " on " | " off " } |"
+.RB "[ " arp " { " on " | " off " } ]"
 .br
-.BR allmulticast " { " on " | " off " } |"
+.RB "[ " dynamic " { " on " | " off " } ]"
 .br
-.BR dynamic " { " on " | " off " } |"
+.RB "[ " multicast " { " on " | " off " } ]"
 .br
-.BR multicast " { " on " | " off " } |"
+.RB "[ " allmulticast " { " on " | " off " } ]"
 .br
-.BR protodown " { " on " | " off " } |"
+.RB "[ " promisc " { " on " | " off " } ]"
 .br
-.B  txqueuelen
-.IR PACKETS " |"
+.RB "[ " protodown " { " on " | " off " } ]"
 .br
-.B  name
-.IR NEWNAME " |"
+.RB "[ " trailers " { " on " | " off " } ]"
 .br
-.B  address
-.IR LLADDR " |"
-.B  broadcast
-.IR LLADDR " |"
+.RB "[ " txqueuelen
+.IR PACKETS " ]"
 .br
-.B  mtu
-.IR MTU " |"
+.RB "[ " name
+.IR NEWNAME " ]"
 .br
-.B  netns
-.IR PID " |"
+.RB "[ " address
+.IR LLADDR " ]"
 .br
-.B  netns
-.IR NETNSNAME " |"
+.RB "[ " broadcast
+.IR LLADDR " ]"
 .br
-.B alias
-.IR NAME  " |"
+.RB "[ " mtu
+.IR MTU " ]"
 .br
-.B vf
+.RB "[ " netns " {"
+.IR PID " | " NETNSNAME " } ]"
+.br
+.RB "[ " link-netnsid
+.IR ID " ]"
+.br
+.RB "[ " alias
+.IR NAME  " ]"
+.br
+.RB "[ " vf
 .IR NUM " ["
 .B  mac
-.IR LLADDR " ] ["
-.B vlan
+.IR LLADDR " ]"
+.br
+.in +9
+.RB "[ " vlan
 .IR VLANID " [ "
 .B qos
-.IR VLAN-QOS " ] ] ["
-.B rate
-.IR TXRATE " ] ["
-.B max_tx_rate
-.IR TXRATE " ] ["
-.B min_tx_rate
-.IR TXRATE " ] ["
-.B spoofchk { on | off } ] [
-.B state { auto | enable | disable}
-] |
+.IR VLAN-QOS " ] ]"
 .br
-.B master
-.IR DEVICE " |"
+.RB "[ " rate
+.IR TXRATE " ]"
+.br
+.RB "[ " max_tx_rate
+.IR TXRATE " ]"
 .br
-.B nomaster " |"
+.RB "[ " min_tx_rate
+.IR TXRATE " ]"
 .br
-.B addrgenmode { eui64 | none | stable_secret | random }
+.RB "[ " spoofchk " { " on " | " off " } ]"
 .br
-.B link-netnsid ID
-.BR " }"
+.RB "[ " state " { " auto " | " enable " | " disable " } ] ]"
+.br
+.in -9
+.RB "[ " master
+.IR DEVICE " ]"
+.br
+.RB "[ " nomaster " ]"
+.br
+.RB "[ " addrgenmode " { " eui64 " | " none " | " stable_secret " | " random " } ]"
 
 
 .ti -8
 .B ip link show
 .RI "[ " DEVICE " | "
 .B group
-.IR GROUP " | "
-.BR up " | "
+.IR GROUP " ] ["
+.BR up " ] ["
 .B master
-.IR DEVICE " | "
+.IR DEVICE " ] ["
 .B type
 .IR TYPE " ]"
 
-- 
2.6.4
