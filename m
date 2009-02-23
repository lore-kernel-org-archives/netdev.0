From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 2/3] Doc: Cleanup whitespaces in ip-sysctl.txt
Date: Mon, 23 Feb 2009 15:39:04 +0100
Message-ID: <1235399945.2351.50.camel@localhost.localdomain>
References: <1235141957.2351.37.camel@localhost.localdomain>
	 <1235142193.2351.41.camel@localhost.localdomain>
	 <20090222.000656.74298101.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:45998 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbZBWOjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 09:39:08 -0500
In-Reply-To: <20090222.000656.74298101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix up whitespaces while going though ip-sysctl.txt anyway.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/networking/ip-sysctl.txt |  118 ++++++++++++++++----------------
 1 files changed, 59 insertions(+), 59 deletions(-)


diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index e0b8c2c..7185e4c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -2,7 +2,7 @@
 
 ip_forward - BOOLEAN
 	0 - disabled (default)
-	not 0 - enabled 
+	not 0 - enabled
 
 	Forward Packets between interfaces.
 
@@ -36,49 +36,49 @@ rt_cache_rebuild_count - INTEGER
 IP Fragmentation:
 
 ipfrag_high_thresh - INTEGER
-	Maximum memory used to reassemble IP fragments. When 
+	Maximum memory used to reassemble IP fragments. When
 	ipfrag_high_thresh bytes of memory is allocated for this purpose,
 	the fragment handler will toss packets until ipfrag_low_thresh
 	is reached.
-	
+
 ipfrag_low_thresh - INTEGER
-	See ipfrag_high_thresh	
+	See ipfrag_high_thresh
 
 ipfrag_time - INTEGER
-	Time in seconds to keep an IP fragment in memory.	
+	Time in seconds to keep an IP fragment in memory.
 
 ipfrag_secret_interval - INTEGER
-	Regeneration interval (in seconds) of the hash secret (or lifetime 
+	Regeneration interval (in seconds) of the hash secret (or lifetime
 	for the hash secret) for IP fragments.
 	Default: 600
 
 ipfrag_max_dist - INTEGER
-	ipfrag_max_dist is a non-negative integer value which defines the 
-	maximum "disorder" which is allowed among fragments which share a 
-	common IP source address. Note that reordering of packets is 
-	not unusual, but if a large number of fragments arrive from a source 
-	IP address while a particular fragment queue remains incomplete, it 
-	probably indicates that one or more fragments belonging to that queue 
-	have been lost. When ipfrag_max_dist is positive, an additional check 
-	is done on fragments before they are added to a reassembly queue - if 
-	ipfrag_max_dist (or more) fragments have arrived from a particular IP 
-	address between additions to any IP fragment queue using that source 
-	address, it's presumed that one or more fragments in the queue are 
-	lost. The existing fragment queue will be dropped, and a new one 
+	ipfrag_max_dist is a non-negative integer value which defines the
+	maximum "disorder" which is allowed among fragments which share a
+	common IP source address. Note that reordering of packets is
+	not unusual, but if a large number of fragments arrive from a source
+	IP address while a particular fragment queue remains incomplete, it
+	probably indicates that one or more fragments belonging to that queue
+	have been lost. When ipfrag_max_dist is positive, an additional check
+	is done on fragments before they are added to a reassembly queue - if
+	ipfrag_max_dist (or more) fragments have arrived from a particular IP
+	address between additions to any IP fragment queue using that source
+	address, it's presumed that one or more fragments in the queue are
+	lost. The existing fragment queue will be dropped, and a new one
 	started. An ipfrag_max_dist value of zero disables this check.
 
 	Using a very small value, e.g. 1 or 2, for ipfrag_max_dist can
 	result in unnecessarily dropping fragment queues when normal
-	reordering of packets occurs, which could lead to poor application 
-	performance. Using a very large value, e.g. 50000, increases the 
-	likelihood of incorrectly reassembling IP fragments that originate 
+	reordering of packets occurs, which could lead to poor application
+	performance. Using a very large value, e.g. 50000, increases the
+	likelihood of incorrectly reassembling IP fragments that originate
 	from different IP datagrams, which could result in data corruption.
 	Default: 64
 
 INET peer storage:
 
 inet_peer_threshold - INTEGER
-	The approximate size of the storage.  Starting from this threshold	
+	The approximate size of the storage.  Starting from this threshold
 	entries will be thrown aggressively.  This threshold also determines
 	entries' time-to-live and time intervals between garbage collection
 	passes.  More entries, less time-to-live, less GC interval.
@@ -105,7 +105,7 @@ inet_peer_gc_maxtime - INTEGER
 	in effect under low (or absent) memory pressure on the pool.
 	Measured in seconds.
 
-TCP variables: 
+TCP variables:
 
 somaxconn - INTEGER
 	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
@@ -310,7 +310,7 @@ tcp_orphan_retries - INTEGER
 
 tcp_reordering - INTEGER
 	Maximal reordering of packets in a TCP stream.
-	Default: 3	
+	Default: 3
 
 tcp_retrans_collapse - BOOLEAN
 	Bug-to-bug compatibility with some broken printers.
@@ -521,7 +521,7 @@ IP Variables:
 
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
-	choose the local port. The first number is the first, the 
+	choose the local port. The first number is the first, the
 	second the last local port number. Default value depends on
 	amount of memory available on the system:
 	> 128Mb 32768-61000
@@ -594,12 +594,12 @@ icmp_errors_use_inbound_ifaddr - BOOLEAN
 
 	If zero, icmp error messages are sent with the primary address of
 	the exiting interface.
- 
+
 	If non-zero, the message will be sent with the primary address of
 	the interface that received the packet that caused the icmp error.
 	This is the behaviour network many administrators will expect from
 	a router. And it can make debugging complicated network layouts
-	much easier. 
+	much easier.
 
 	Note that if no primary address exists for the interface selected,
 	then the primary address of the first non-loopback interface that
@@ -611,7 +611,7 @@ igmp_max_memberships - INTEGER
 	Change the maximum number of multicast groups we can subscribe to.
 	Default: 20
 
-conf/interface/*  changes special settings per interface (where "interface" is 
+conf/interface/*  changes special settings per interface (where "interface" is
 		  the name of your network interface)
 conf/all/*	  is special, changes the settings for all interfaces
 
@@ -625,11 +625,11 @@ log_martians - BOOLEAN
 accept_redirects - BOOLEAN
 	Accept ICMP redirect messages.
 	accept_redirects for the interface will be enabled if:
-	- both conf/{all,interface}/accept_redirects are TRUE in the case forwarding
-	  for the interface is enabled
+	- both conf/{all,interface}/accept_redirects are TRUE in the case
+	  forwarding for the interface is enabled
 	or
-	- at least one of conf/{all,interface}/accept_redirects is TRUE in the case
-	  forwarding for the interface is disabled
+	- at least one of conf/{all,interface}/accept_redirects is TRUE in the
+	  case forwarding for the interface is disabled
 	accept_redirects for the interface will be disabled otherwise
 	default TRUE (host)
 		FALSE (router)
@@ -640,8 +640,8 @@ forwarding - BOOLEAN
 mc_forwarding - BOOLEAN
 	Do multicast routing. The kernel needs to be compiled with CONFIG_MROUTE
 	and a multicast routing daemon is required.
-	conf/all/mc_forwarding must also be set to TRUE to enable multicast routing
-	for the interface
+	conf/all/mc_forwarding must also be set to TRUE to enable multicast
+	routing	for the interface
 
 medium_id - INTEGER
 	Integer value used to differentiate the devices by the medium they
@@ -649,7 +649,7 @@ medium_id - INTEGER
 	the broadcast packets are received only on one of them.
 	The default value 0 means that the device is the only interface
 	to its medium, value of -1 means that medium is not known.
-	
+
 	Currently, it is used to change the proxy_arp behavior:
 	the proxy_arp feature is enabled for packets forwarded between
 	two devices attached to different media.
@@ -710,9 +710,9 @@ rp_filter - INTEGER
 	    and if the source address is not reachable via any interface
 	    the packet check will fail.
 
-        Current recommended practice in RFC3704 is to enable strict mode
+	Current recommended practice in RFC3704 is to enable strict mode
 	to prevent IP spoofing from DDos attacks. If using asymmetric routing
-        or other complicated routing, then loose mode is recommended.
+	or other complicated routing, then loose mode is recommended.
 
 	conf/all/rp_filter must also be set to non-zero to do source validation
 	on the interface
@@ -835,7 +835,7 @@ apply to IPv6 [XXX?].
 
 bindv6only - BOOLEAN
 	Default value for IPV6_V6ONLY socket option,
-	which restricts use of the IPv6 socket to IPv6 communication 
+	which restricts use of the IPv6 socket to IPv6 communication
 	only.
 		TRUE: disable IPv4-mapped address feature
 		FALSE: enable IPv4-mapped address feature
@@ -845,19 +845,19 @@ bindv6only - BOOLEAN
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
-	Maximum memory used to reassemble IPv6 fragments. When 
+	Maximum memory used to reassemble IPv6 fragments. When
 	ip6frag_high_thresh bytes of memory is allocated for this purpose,
 	the fragment handler will toss packets until ip6frag_low_thresh
 	is reached.
-	
+
 ip6frag_low_thresh - INTEGER
-	See ip6frag_high_thresh	
+	See ip6frag_high_thresh
 
 ip6frag_time - INTEGER
 	Time in seconds to keep an IPv6 fragment in memory.
 
 ip6frag_secret_interval - INTEGER
-	Regeneration interval (in seconds) of the hash secret (or lifetime 
+	Regeneration interval (in seconds) of the hash secret (or lifetime
 	for the hash secret) for IPv6 fragments.
 	Default: 600
 
@@ -866,17 +866,17 @@ conf/default/*:
 
 
 conf/all/*:
-	Change all the interface-specific settings.  
+	Change all the interface-specific settings.
 
 	[XXX:  Other special features than forwarding?]
 
 conf/all/forwarding - BOOLEAN
-	Enable global IPv6 forwarding between all interfaces.  
+	Enable global IPv6 forwarding between all interfaces.
 
-	IPv4 and IPv6 work differently here; e.g. netfilter must be used 
+	IPv4 and IPv6 work differently here; e.g. netfilter must be used
 	to control which interfaces may forward packets and which not.
 
-	This also sets all interfaces' Host/Router setting 
+	This also sets all interfaces' Host/Router setting
 	'forwarding' to the specified value.  See below for details.
 
 	This referred to as global forwarding.
@@ -887,12 +887,12 @@ proxy_ndp - BOOLEAN
 conf/interface/*:
 	Change special settings per interface.
 
-	The functional behaviour for certain settings is different 
+	The functional behaviour for certain settings is different
 	depending on whether local forwarding is enabled or not.
 
 accept_ra - BOOLEAN
 	Accept Router Advertisements; autoconfigure using them.
-	
+
 	Functional default: enabled if local forwarding is disabled.
 			    disabled if local forwarding is enabled.
 
@@ -938,7 +938,7 @@ accept_source_route - INTEGER
 	Default: 0
 
 autoconf - BOOLEAN
-	Autoconfigure addresses using Prefix Information in Router 
+	Autoconfigure addresses using Prefix Information in Router
 	Advertisements.
 
 	Functional default: enabled if accept_ra_pinfo is enabled.
@@ -947,11 +947,11 @@ autoconf - BOOLEAN
 dad_transmits - INTEGER
 	The amount of Duplicate Address Detection probes to send.
 	Default: 1
-	
+
 forwarding - BOOLEAN
-	Configure interface-specific Host/Router behaviour.  
+	Configure interface-specific Host/Router behaviour.
 
-	Note: It is recommended to have the same setting on all 
+	Note: It is recommended to have the same setting on all
 	interfaces; mixed router/host scenarios are rather uncommon.
 
 	FALSE:
@@ -960,13 +960,13 @@ forwarding - BOOLEAN
 
 	1. IsRouter flag is not set in Neighbour Advertisements.
 	2. Router Solicitations are being sent when necessary.
-	3. If accept_ra is TRUE (default), accept Router 
+	3. If accept_ra is TRUE (default), accept Router
 	   Advertisements (and do autoconfiguration).
 	4. If accept_redirects is TRUE (default), accept Redirects.
 
 	TRUE:
 
-	If local forwarding is enabled, Router behaviour is assumed. 
+	If local forwarding is enabled, Router behaviour is assumed.
 	This means exactly the reverse from the above:
 
 	1. IsRouter flag is set in Neighbour Advertisements.
@@ -1001,7 +1001,7 @@ router_solicitation_interval - INTEGER
 	Default: 4
 
 router_solicitations - INTEGER
-	Number of Router Solicitations to send until assuming no 
+	Number of Router Solicitations to send until assuming no
 	routers are present.
 	Default: 3
 
@@ -1025,11 +1025,11 @@ temp_prefered_lft - INTEGER
 
 max_desync_factor - INTEGER
 	Maximum value for DESYNC_FACTOR, which is a random value
-	that ensures that clients don't synchronize with each 
+	that ensures that clients don't synchronize with each
 	other and generate new addresses at exactly the same time.
 	value is in seconds.
 	Default: 600
-	
+
 regen_max_retry - INTEGER
 	Number of attempts before give up attempting to generate
 	valid temporary addresses.
@@ -1037,8 +1037,8 @@ regen_max_retry - INTEGER
 
 max_addresses - INTEGER
 	Number of maximum addresses per interface.  0 disables limitation.
-	It is recommended not set too large value (or 0) because it would 
-	be too easy way to crash kernel to allow to create too much of 
+	It is recommended not set too large value (or 0) because it would
+	be too easy way to crash kernel to allow to create too much of
 	autoconfigured addresses.
 	Default: 16
 

