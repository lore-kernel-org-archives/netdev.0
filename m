From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 6/6] ip-link.8: Fix font choices
Date: Sat,  9 Jul 2016 11:22:50 +0200
Message-ID: <1468056170-6056-7-git-send-email-phil@nwl.cc>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38229 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933103AbcGIJXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:10 -0400
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 92 ++++++++++++++++++++++++++-------------------------
 1 file changed, 47 insertions(+), 45 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ada20fe210793..1644af0ef9f9f 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -304,7 +304,7 @@ the following additional arguments are supported:
 .BI "ip link add
 .BI link " DEVICE "
 .BI name " NAME "
-.BI type " vlan "
+.B "type vlan"
 [
 .BI protocol " VLAN_PROTO "
 ]
@@ -406,7 +406,7 @@ For a link of type
 the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
-.BI type " vxlan " id " ID"
+.BI type " vxlan " id " VNI"
 [
 .BI dev " PHYS_DEV "
 .RB " ] [ { " group " | " remote " } "
@@ -425,27 +425,27 @@ the following additional arguments are supported:
 ] [
 .BI srcport " MIN MAX "
 ] [
-.I "[no]learning "
+.RB [ no ] learning
 ] [
-.I "[no]proxy "
+.RB [ no ] proxy
 ] [
-.I "[no]rsc "
+.RB [ no ] rsc
 ] [
-.I "[no]l2miss "
+.RB [ no ] l2miss
 ] [
-.I "[no]l3miss "
+.RB [ no ] l3miss
 ] [
-.I "[no]udpcsum "
+.RB [ no ] udpcsum
 ] [
-.I "[no]udp6zerocsumtx "
+.RB [ no ] udp6zerocsumtx
 ] [
-.I "[no]udp6zerocsumrx "
+.RB [ no ] udp6zerocsumrx
 ] [
 .BI ageing " SECONDS "
 ] [
 .BI maxaddress " NUMBER "
 ] [
-.RI "[no]external "
+.RB [ no ] external
 ] [
 .B gbp
 ] [
@@ -502,36 +502,36 @@ parameter.
 source ports to communicate to the remote VXLAN tunnel endpoint.
 
 .sp
-.I [no]learning
+.RB [ no ] learning
 - specifies if unknown source link layer addresses and IP addresses
 are entered into the VXLAN device forwarding database.
 
 .sp
-.I [no]rsc
+.RB [ no ] rsc
 - specifies if route short circuit is turned on.
 
 .sp
-.I [no]proxy
+.RB [ no ] proxy
 - specifies ARP proxy is turned on.
 
 .sp
-.I [no]l2miss
+.RB [ no ] l2miss
 - specifies if netlink LLADDR miss notifications are generated.
 
 .sp
-.I [no]l3miss
+.RB [ no ] l3miss
 - specifies if netlink IP ADDR miss notifications are generated.
 
 .sp
-.I [no]udpcsum
+.RB [ no ] udpcsum
 - specifies if UDP checksum is calculated for transmitted packets over IPv4.
 
 .sp
-.I [no]udp6zerocsumtx
+.RB [ no ] udp6zerocsumtx
 - skip UDP checksum calculation for transmitted packets over IPv6.
 
 .sp
-.I [no]udp6zerocsumrx
+.RB [ no ] udp6zerocsumrx
 - allow incoming UDP packets over IPv6 with zero checksum field.
 
 .sp
@@ -543,7 +543,7 @@ are entered into the VXLAN device forwarding database.
 - specifies the maximum number of FDB entries.
 
 .sp
-.I [no]external
+.RB [ no ] external
 - specifies whether an external control plane
 .RB "(e.g. " "ip route encap" )
 or the internal FDB should be used.
@@ -607,18 +607,18 @@ For a link of types
 the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
-.BR type " { gre | ipip | sit } "
+.BR type " { " gre " | " ipip " | " sit " }"
 .BI " remote " ADDR " local " ADDR
 [
-.BR encap " { fou | gue | none } "
+.BR encap " { " fou " | " gue " | " none " }"
 ] [
-.BI "encap-sport { " PORT " | auto } "
+.BR encap-sport " { " \fIPORT " | " auto " }"
 ] [
 .BI "encap-dport " PORT
 ] [
-.I " [no]encap-csum "
+.RB [ no ] encap-csum
 ] [
-.I " [no]encap-remcsum "
+.RB [ no ] encap-remcsum
 ]
 
 .in +8
@@ -632,12 +632,12 @@ the following additional arguments are supported:
 It must be an address on another interface on this host.
 
 .sp
-.BR encap " { fou | gue | none } "
+.BR encap " { " fou " | " gue " | " none " }"
 - specifies type of secondary UDP encapsulation. "fou" indicates
 Foo-Over-UDP, "gue" indicates Generic UDP Encapsulation.
 
 .sp
-.BI "encap-sport { " PORT " | auto } "
+.BR encap-sport " { " \fIPORT " | " auto " }"
 - specifies the source port in UDP encapsulation.
 .IR PORT
 indicates the port by number, "auto"
@@ -646,12 +646,12 @@ indicates that the port number should be chosen automatically
 encapsulated packet).
 
 .sp
-.I [no]encap-csum
+.RB [ no ] encap-csum
 - specifies if UDP checksums are enabled in the secondary
 encapsulation.
 
 .sp
-.I [no]encap-remcsum
+.RB [ no ] encap-remcsum
 - specifies if Remote Checksum Offload is enabled. This is only
 applicable for Generic UDP Encapsulation.
 
@@ -664,13 +664,15 @@ For a link of type
 the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
-.BI type " { ip6gre | ip6gretap }  " remote " ADDR " local " ADDR
+.BR type " { " ip6gre " | " ip6gretap " }"
+.BI remote " ADDR " local " ADDR"
 [
-.I "[i|o]seq]"
+.RB [ i | o ] seq
 ] [
-.I "[i|o]key" KEY
+.RB [ i | o ] key
+.I KEY
 ] [
-.I " [i|o]csum "
+.RB [ i | o ] csum
 ] [
 .BI hoplimit " TTL "
 ] [
@@ -696,7 +698,7 @@ the following additional arguments are supported:
 It must be an address on another interface on this host.
 
 .sp
-.BI  [i|o]seq
+.RB  [ i | o ] seq
 - serialize packets.
 The
 .B oseq
@@ -706,7 +708,7 @@ The
 flag requires that all input packets are serialized.
 
 .sp
-.BI  [i|o]key " KEY"
+.RB  [ i | o ] key " \fIKEY"
 - use keyed GRE with key
 .IR KEY ". "KEY
 is either a number or an IPv4 address-like dotted quad.
@@ -718,7 +720,7 @@ The
 parameters specify different keys for input and output.
 
 .sp
-.BI  [i|o]csum
+.RB  [ i | o ] csum
 - generate/require checksums for tunneled packets.
 The
 .B ocsum
@@ -770,7 +772,7 @@ For a link of type
 the following additional arguments are supported:
 
 .BI "ip link add " DEVICE " name " NAME
-.BI type " ipoib [ " pkey " PKEY ] [" mode " MODE " ]
+.BR "type ipoib " [ " pkey \fIPKEY" " ] [ " mode " \fIMODE \fR]"
 
 .in +8
 .sp
@@ -787,7 +789,7 @@ For a link of type
 the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
-.BI type " geneve " id " ID " remote " IPADDR"
+.BI type " geneve " id " VNI " remote " IPADDR"
 [
 .BI ttl " TTL "
 ] [
@@ -830,7 +832,7 @@ the following additional arguments are supported:
 .BI "ip link add link " DEVICE " name " NAME
 .BR type " { " macvlan " | " macvtap " } "
 .BR mode " { " private " | " vepa " | " bridge " | " passthru
-.BR " [ " nopromisc " ] } "
+.RB " [ " nopromisc " ] } "
 
 .in +8
 .sp
@@ -875,11 +877,11 @@ For a link of type
 .I HSR
 the following additional arguments are supported:
 
-.BI "ip link add link " DEVICE " name " NAME
-.BI type " hsr "
+.BI "ip link add link " DEVICE " name " NAME " type hsr"
 .BI slave1 " SLAVE1-IF " slave2 " SLAVE2-IF "
-.BR " [ supervision " ADDR-BYTE "  ] "
-.BR " [ version  { " 0 " | " 1 " } ] "
+.RB [ " supervision"
+.IR ADDR-BYTE " ] ["
+.BR version " { " 0 " | " 1 " } ]"
 
 .in +8
 .sp
@@ -892,11 +894,11 @@ the following additional arguments are supported:
 .BI slave2 " SLAVE2-IF "
 - Specifies the physical device used for the second of the two ring ports.
 
-.BR "supervision ADDR-BYTE "
+.BI supervision " ADDR-BYTE"
 - The last byte of the multicast address used for HSR supervision frames.
 Default option is "0", possible values 0-255.
 
-.BR "version { 0 | 1 }"
+.BR version " { " 0 " | " 1 " }"
 - Selects the protocol version of the interface. Default option is "0", which
 corresponds to the 2010 version of the HSR standard. Option "1" activates the
 2012 version.
-- 
2.8.2
