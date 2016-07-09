From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/6] ip-link.8: Extend type list in synopsis
Date: Sat,  9 Jul 2016 11:22:47 +0200
Message-ID: <1468056170-6056-4-git-send-email-phil@nwl.cc>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50364 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933103AbcGIJX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:28 -0400
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'ip link set' supports passing a type to set type-specific parameters.
Add this missing piece of information to the synopsis section.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 71 +++++++++++++++++++++++++++++----------------------
 1 file changed, 40 insertions(+), 31 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ad18f7555d0a5..4fc5f3c6257e5 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -40,35 +40,6 @@ ip-link \- network device configuration
 .RI "[ " ARGS " ]"
 
 .ti -8
-.IR TYPE " := [ "
-.BR bridge " | "
-.BR bond " | "
-.BR can " | "
-.BR dummy " | "
-.BR hsr " | "
-.BR ifb " | "
-.BR ipoib " |"
-.BR macvlan  " | "
-.BR macvtap  " | "
-.BR vcan " | "
-.BR veth " | "
-.BR vlan " | "
-.BR vxlan " |"
-.BR ip6tnl " |"
-.BR ipip " |"
-.BR sit " |"
-.BR gre " |"
-.BR gretap " |"
-.BR ip6gre " |"
-.BR ip6gretap " |"
-.BR vti " |"
-.BR nlmon " |"
-.BR ipvlan " |"
-.BR lowpan " |"
-.BR geneve " |"
-.BR vrf " ]"
-
-.ti -8
 .BR "ip link delete " {
 .IR DEVICE " | "
 .BI "group " GROUP
@@ -80,7 +51,12 @@ ip-link \- network device configuration
 .BR "ip link set " {
 .IR DEVICE " | "
 .BI "group " GROUP
-.RB "} [ { " up " | " down " } ]"
+}
+.br
+.RB "[ { " up " | " down " } ]"
+.br
+.RB "[ " type
+.IR "ETYPE TYPE_ARGS" " ]"
 .br
 .RB "[ " arp " { " on " | " off " } ]"
 .br
@@ -169,7 +145,7 @@ ip-link \- network device configuration
 .B master
 .IR DEVICE " ] ["
 .B type
-.IR TYPE " ]"
+.IR ETYPE " ]"
 .B vrf
 .IR NAME " ]"
 
@@ -177,6 +153,39 @@ ip-link \- network device configuration
 .B ip link help
 .RI "[ " TYPE " ]"
 
+.ti -8
+.IR TYPE " := [ "
+.BR bridge " | "
+.BR bond " | "
+.BR can " | "
+.BR dummy " | "
+.BR hsr " | "
+.BR ifb " | "
+.BR ipoib " |"
+.BR macvlan  " | "
+.BR macvtap  " | "
+.BR vcan " | "
+.BR veth " | "
+.BR vlan " | "
+.BR vxlan " |"
+.BR ip6tnl " |"
+.BR ipip " |"
+.BR sit " |"
+.BR gre " |"
+.BR gretap " |"
+.BR ip6gre " |"
+.BR ip6gretap " |"
+.BR vti " |"
+.BR nlmon " |"
+.BR ipvlan " |"
+.BR lowpan " |"
+.BR geneve " |"
+.BR vrf " ]"
+
+.ti -8
+.IR ETYPE " := [ " TYPE " |"
+.BR bridge_slave " | " bond_slave " ]"
+
 .SH "DESCRIPTION"
 .SS ip link add - add virtual link
 
-- 
2.8.2
