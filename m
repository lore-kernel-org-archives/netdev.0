From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: Fix some manpage typos
Date: Thu,  4 Apr 2013 15:36:57 +0200
Message-ID: <1365082617-3721-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760437Ab3DDNhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 09:37:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes some of the typos found in iproute2
documentation.

Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
---
 man/man8/arpd.8           | 2 +-
 man/man8/bridge.8         | 8 ++++----
 man/man8/ip-l2tp.8        | 4 ++--
 man/man8/ip-link.8.in     | 2 +-
 man/man8/ip-tunnel.8      | 4 ++--
 man/man8/tc-cbq-details.8 | 2 +-
 man/man8/tc-cbq.8         | 2 +-
 man/man8/tc-ematch.8      | 2 +-
 man/man8/tc-fq_codel.8    | 2 +-
 9 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/man/man8/arpd.8 b/man/man8/arpd.8
index 6b9a43a..fc99b97 100644
--- a/man/man8/arpd.8
+++ b/man/man8/arpd.8
@@ -26,7 +26,7 @@ Read and load an arpd database from FILE in a text fo=
rmat similar to that dumped
 the location of the database file. The default location is /var/lib/ar=
pd/arpd.db
 .TP
 -a <NUMBER>
-With this option, arpd not only passively listens for ARP packets on t=
he interface, but also sends brodcast queries itself. NUMBER is the num=
ber of such queries to make before a destination is considered dead. Wh=
en arpd is started as kernel helper (i.e. with app_solicit enabled in s=
ysctl or even with option -k) without this option and still did not lea=
rn enough information, you can observe 1 second gaps in service. Not fa=
tal, but not good.
+With this option, arpd not only passively listens for ARP packets on t=
he interface, but also sends broadcast queries itself. NUMBER is the nu=
mber of such queries to make before a destination is considered dead. W=
hen arpd is started as kernel helper (i.e. with app_solicit enabled in =
sysctl or even with option -k) without this option and still did not le=
arn enough information, you can observe 1 second gaps in service. Not f=
atal, but not good.
 .TP
 -k
 Suppress sending broadcast queries by the kernel. This option only mak=
es sense together with option -a.
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 8513a5a..9be0c20 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -178,7 +178,7 @@ adress tables.
 .sp
=20
 .B 4
-- STP BLOCKING state.  Only valid if STP is eanbled on the bridge.  Th=
is state
+- STP BLOCKING state.  Only valid if STP is enabled on the bridge.  Th=
is state
 is used during the STP election process.  In this state, port will onl=
y process
 STP BPDUs.
 .sp
@@ -198,7 +198,7 @@ traffic back out of the receiving port.
 .TP
 .BR "fastleave on " or " fastleave off "
 This flag allows the bridge to immediately stop multicast traffic on a=
 port
-that recieves IGMP Leave message.  It is only used with IGMP snooping =
is
+that receives IGMP Leave message.  It is only used with IGMP snooping =
is
 enabled on the bridge.  By default the flag is off.
=20
 .TP
@@ -307,7 +307,7 @@ device is the bridge device.
=20
 .TP
 .BI master
-the vlan is configured on the sofware bridge (default).
+the vlan is configured on the software bridge (default).
=20
 .SS bridge vlan delete - delete a forwarding database entry
 This command removes an existing fdb entry.
@@ -361,7 +361,7 @@ the bridge device is not part of the syntax. This i=
s a limitation of the
 underlying netlink neighbour message protocol. When displaying the
 forwarding table, entries for all bridges are displayed.
 Add/delete/modify commands determine the underlying bridge device
-based on the bridge to which the coresponding ethernet device is attac=
hed.=20
+based on the bridge to which the corresponding ethernet device is atta=
ched.
=20
=20
 .SH SEE ALSO
diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 463878f..2efda9f 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -108,7 +108,7 @@ control protocol so no userspace daemon is required=
 - tunnels are
 manually created by issuing commands at a local system and at a remote
 peer.
 .PP
-L2TPv3 is suitable for Layer-2 tunnelling. Static tunnels are useful
+L2TPv3 is suitable for Layer-2 tunneling. Static tunnels are useful
 to establish network links across IP networks when the tunnels are
 fixed. L2TPv3 tunnels can carry data of more than one session. Each
 session is identified by a session_id and its parent tunnel's
@@ -366,7 +366,7 @@ site-B:# modprobe nf_degrag_ipv4
 .fi
 .PP
 If L2TP is being used over IPv6, use the IPv6 degrag module.
-.SH INTEROPABILITY
+.SH INTEROPERABILITY
 .PP
 Unmanaged (static) L2TPv3 tunnels are supported by some network
 equipment equipment vendors such as Cisco.
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8d2a6f9..2e89efe 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -212,7 +212,7 @@ specifies the physical device to act operate on.
 .TP
 .BI dev " DEVICE "
 .I DEVICE
-specifies network device to operate on. When configuring SR-IOV Virtua=
l Fuction
+specifies network device to operate on. When configuring SR-IOV Virtua=
l Function
 (VF) devices, this keyword should specify the associated Physical Func=
tion (PF)
 device.
=20
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index 3e558b0..cb05a4b 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -84,7 +84,7 @@ ip-tunnel - tunnel configuration
 .B tunnel
 objects are tunnels, encapsulating packets in IP packets and then
 sending them over the IP infrastructure.
-The encapulating (or outer) address family is specified by the
+The encapsulating (or outer) address family is specified by the
 .B -f
 option.  The default is IPv4.
=20
@@ -163,7 +163,7 @@ changes.
 .B nopmtudisc
 disable Path MTU Discovery on this tunnel.
 It is enabled by default.  Note that a fixed ttl is incompatible
-with this option: tunnelling with a fixed ttl always makes pmtu
+with this option: tunneling with a fixed ttl always makes pmtu
 discovery.
=20
 .TP
diff --git a/man/man8/tc-cbq-details.8 b/man/man8/tc-cbq-details.8
index 09badb9..f43dca8 100644
--- a/man/man8/tc-cbq-details.8
+++ b/man/man8/tc-cbq-details.8
@@ -273,7 +273,7 @@ are still deemed to have this size. Defaults to zer=
o.
 .TP
 ewma log
 When CBQ needs to measure the average idle time, it does so using an=20
-Exponentially Weighted Moving Average which smoothes out measurements =
into
+Exponentially Weighted Moving Average which smooths out measurements i=
nto
 a moving average. The EWMA LOG determines how much smoothing occurs. D=
efaults=20
 to 5. Lower values imply greater sensitivity. Must be between 0 and 31=
=2E
 .P
diff --git a/man/man8/tc-cbq.8 b/man/man8/tc-cbq.8
index 79fb93b..4b371a0 100644
--- a/man/man8/tc-cbq.8
+++ b/man/man8/tc-cbq.8
@@ -184,7 +184,7 @@ are still deemed to have this size. Defaults to zer=
o.
 .TP
 ewma log
 When CBQ needs to measure the average idle time, it does so using an=20
-Exponentially Weighted Moving Average which smoothes out measurements =
into
+Exponentially Weighted Moving Average which smooths out measurements i=
nto
 a moving average. The EWMA LOG determines how much smoothing occurs. L=
ower=20
 values imply greater sensitivity. Must be between 0 and 31. Defaults=20
 to 5.
diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
index 957a22e..567ce7d 100644
--- a/man/man8/tc-ematch.8
+++ b/man/man8/tc-ematch.8
@@ -99,7 +99,7 @@ u32 ematch
 .IR ALIGN " :=3D { " u8 " | " u16 " | " u32 " }
=20
 .SS ipset
-test packet agains ipset membership
+test packet against ipset membership
 .ti
 .IR ipset "( " SETNAME " " FLAGS " )
=20
diff --git a/man/man8/tc-fq_codel.8 b/man/man8/tc-fq_codel.8
index 8b43c10..adeacd6 100644
--- a/man/man8/tc-fq_codel.8
+++ b/man/man8/tc-fq_codel.8
@@ -20,7 +20,7 @@ BYTES ] [
 ]
=20
 .SH DESCRIPTION
-FQ_Codel (Fair Queuing Controled Delay) is queuing discipline that com=
bines Fair
+FQ_Codel (Fair Queuing Controlled Delay) is queuing discipline that co=
mbines Fair
 Queuing with the CoDel AQM scheme. FQ_Codel uses a stochastic model to=
 classify
 incoming packets into different flows and is used to provide a fair sh=
are of the
 bandwidth to all the flows using the queue. Each such flow is managed =
by the
--=20
1.8.1.4
