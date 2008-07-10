From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] ip: sysctl documentation cleanup
Date: Thu, 10 Jul 2008 14:39:07 -0700
Message-ID: <20080710143907.29b6be10@extreme>
References: <20080701154306.21b04c75@extreme>
	<Pine.LNX.4.64.0807011549340.26330@shark.he.net>
	<20080701161357.3ddccd2f@speedy>
	<20080701.192838.153872666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59726 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbYGJVjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:39:13 -0400
In-Reply-To: <20080701.192838.153872666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduced version of the spelling cleanup patch.
Take out the confusing language in tcp_frto, and organize the undocumented
values.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/Documentation/networking/ip-sysctl.txt	2008-07-07 11:16:14.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2008-07-07 11:17:23.000000000 -0700
@@ -148,9 +148,9 @@ tcp_available_congestion_control - STRIN
 	but not loaded.
 
 tcp_base_mss - INTEGER
-	The initial value of search_low to be used by Packetization Layer
-	Path MTU Discovery (MTU probing).  If MTU probing is enabled,
-	this is the inital MSS used by the connection.
+	The initial value of search_low to be used by the packetization layer
+	Path MTU discovery (MTU probing).  If MTU probing is enabled,
+	this is the initial MSS used by the connection.
 
 tcp_congestion_control - STRING
 	Set the congestion control algorithm to be used for new
@@ -185,10 +185,9 @@ tcp_frto - INTEGER
 	timeouts.  It is particularly beneficial in wireless environments
 	where packet loss is typically due to random radio interference
 	rather than intermediate router congestion.  F-RTO is sender-side
-	only modification.  Therefore it does not require any support from
-	the peer, but in a typical case, however, where wireless link is
-	the local access link and most of the data flows downlink, the
-	faraway servers should have F-RTO enabled to take advantage of it.
+	only modification. Therefore it does not require any support from
+	the peer.
+
 	If set to 1, basic version is enabled.  2 enables SACK enhanced
 	F-RTO if flow uses SACK.  The basic version can be used also when
 	SACK is in use though scenario(s) with it exists where F-RTO
@@ -276,7 +275,7 @@ tcp_mem - vector of 3 INTEGERs: min, pre
 	memory.
 
 tcp_moderate_rcvbuf - BOOLEAN
-	If set, TCP performs receive buffer autotuning, attempting to
+	If set, TCP performs receive buffer auto-tuning, attempting to
 	automatically size the buffer (no greater than tcp_rmem[2]) to
 	match the size required by the path for full throughput.  Enabled by
 	default.
@@ -358,7 +357,7 @@ tcp_slow_start_after_idle - BOOLEAN
 	Default: 1
 
 tcp_stdurg - BOOLEAN
-	Use the Host requirements interpretation of the TCP urg pointer field.
+	Use the Host requirements interpretation of the TCP urgent pointer field.
 	Most hosts use the older BSD interpretation, so if you turn this on
 	Linux might not communicate correctly with them.
 	Default: FALSE
@@ -371,12 +370,12 @@ tcp_synack_retries - INTEGER
 tcp_syncookies - BOOLEAN
 	Only valid when the kernel was compiled with CONFIG_SYNCOOKIES
 	Send out syncookies when the syn backlog queue of a socket
-	overflows. This is to prevent against the common 'syn flood attack'
+	overflows. This is to prevent against the common 'SYN flood attack'
 	Default: FALSE
 
 	Note, that syncookies is fallback facility.
 	It MUST NOT be used to help highly loaded servers to stand
-	against legal connection rate. If you see synflood warnings
+	against legal connection rate. If you see SYN flood warnings
 	in your logs, but investigation	shows that they occur
 	because of overload with legal connections, you should tune
 	another parameters until this warning disappear.
@@ -386,7 +385,7 @@ tcp_syncookies - BOOLEAN
 	to use TCP extensions, can result in serious degradation
 	of some services (f.e. SMTP relaying), visible not by you,
 	but your clients and relays, contacting you. While you see
-	synflood warnings in logs not being really flooded, your server
+	SYN flood warnings in logs not being really flooded, your server
 	is seriously misconfigured.
 
 tcp_syn_retries - INTEGER
@@ -1072,25 +1071,24 @@ bridge-nf-filter-pppoe-tagged - BOOLEAN
 	0 : disable this.
 	Default: 1
 
-
 UNDOCUMENTED:
 
-dev_weight FIXME
-discovery_slots FIXME
-discovery_timeout FIXME
-fast_poll_increase FIXME
-ip6_queue_maxlen FIXME
-lap_keepalive_time FIXME
-lo_cong FIXME
-max_baud_rate FIXME
-max_dgram_qlen FIXME
-max_noreply_time FIXME
-max_tx_data_size FIXME
-max_tx_window FIXME
-min_tx_turn_time FIXME
-mod_cong FIXME
-no_cong FIXME
-no_cong_thresh FIXME
-slot_timeout FIXME
-warn_noreply_time FIXME
+/proc/sys/net/core/*
+	dev_weight FIXME
+
+/proc/sys/net/unix/*
+	max_dgram_qlen FIXME
+
+/proc/sys/net/irda/*
+	fast_poll_increase FIXME
+	warn_noreply_time FIXME
+	discovery_slots FIXME
+	slot_timeout FIXME
+	max_baud_rate FIXME
+	discovery_timeout FIXME
+	lap_keepalive_time FIXME
+	max_noreply_time FIXME
+	max_tx_data_size FIXME
+	max_tx_window FIXME
+	min_tx_turn_time FIXME
 
