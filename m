From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 10/20] man: ip-link.8: Fix and improve synopsis
Date: Wed,  2 Mar 2016 19:19:58 +0100
Message-ID: <1456942808-15946-11-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50354 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474AbcCBSWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:22:07 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reflect that it is possible to pass multiple parameters at the same
time, also use the same trick the help text uses to emphasize vf
specific parameters.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 100 +++++++++++++++++++++++++++-----------------------
 1 file changed, 55 insertions(+), 45 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 2376f1653a8f2..e402fdd033165 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -92,79 +92,89 @@ ip-link \- network device configuration
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
+.br
+.RB "[ " name
+.IR NEWNAME " ]"
+.br
+.RB "[ " address
+.IR LLADDR " ]"
 .br
-.B  mtu
-.IR MTU " |"
+.RB "[ " broadcast
+.IR LLADDR " ]"
+.br
+.RB "[ " mtu
+.IR MTU " ]"
 .br
-.B  netns
-.IR PID " |"
+.RB "[ " netns " {"
+.IR PID " | " NETNSNAME " } ]"
 .br
-.B  netns
-.IR NETNSNAME " |"
+.RB "[ " link-netnsid
+.IR ID " ]"
 .br
-.B alias
-.IR NAME  " |"
+.RB "[ " alias
+.IR NAME  " ]"
 .br
-.B vf
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
-.B state { auto | enable | disable} ] [
-.B trust { on | off }
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
+.br
+.RB "[ " min_tx_rate
+.IR TXRATE " ]"
 .br
-.B nomaster " |"
+.RB "[ " spoofchk " { " on " | " off " } ]"
 .br
-.B addrgenmode { eui64 | none | stable_secret | random }
+.RB "[ " state " { " auto " | " enable " | " disable " } ]"
 .br
-.B link-netnsid ID
-.BR " }"
+.RB "[ " trust " { " on " | " off " } ] ]"
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
2.7.2
