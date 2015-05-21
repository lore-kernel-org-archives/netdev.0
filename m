From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v3 03/10] pktgen: doc were missing several config
	options
Date: Thu, 21 May 2015 12:16:26 +0200
Message-ID: <20150521101622.15148.17024.stgit@ivy>
References: <20150521101501.15148.10609.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbbEUKQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:16:33 -0400
In-Reply-To: <20150521101501.15148.10609.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pktgen.txt documentation over available config options were not complete.
Making the list complete by adding the following.

Pgcontrol commands:
 reset

Device commands:
 burst
 queue_map_min
 queue_map_max
 skb_priority
 tos
 traffic_class
 node
 spi
 dst6_max
 dst6_min
 vlan_cfi
 vlan_id
 vlan_p
 svlan_cfi
 svlan_id
 svlan_p

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/pktgen.txt |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 62f5ebb..d255434 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -241,6 +241,7 @@ Current commands and configuration options
 
 start
 stop
+reset
 
 ** Thread commands:
 
@@ -252,6 +253,7 @@ rem_device_all
 
 count
 clone_skb
+burst
 debug
 
 frags
@@ -264,6 +266,13 @@ pkt_size
 min_pkt_size
 max_pkt_size
 
+queue_map_min
+queue_map_max
+skb_priority
+
+tos           (ipv4)
+traffic_class (ipv6)
+
 mpls
 
 udp_src_min
@@ -272,6 +281,8 @@ udp_src_max
 udp_dst_min
 udp_dst_max
 
+node
+
 flag
   IPSRC_RND
   IPDST_RND
@@ -292,6 +303,8 @@ flag
   NODE_ALLOC
   NO_TIMESTAMP
 
+spi (ipsec)
+
 dst_min
 dst_max
 
@@ -303,8 +316,10 @@ src_mac
 
 clear_counters
 
-dst6
 src6
+dst6
+dst6_max
+dst6_min
 
 flows
 flowlen
@@ -314,6 +329,14 @@ ratep
 
 xmit_mode <start_xmit|netif_receive>
 
+vlan_cfi
+vlan_id
+vlan_p
+
+svlan_cfi
+svlan_id
+svlan_p
+
 
 References:
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
