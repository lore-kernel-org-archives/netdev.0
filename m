From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v2 01/10] pktgen: remove obsolete
	"max_before_softirq" from pktgen doc
Date: Thu, 21 May 2015 12:11:42 +0200
Message-ID: <20150521101138.15044.96023.stgit@ivy>
References: <20150521101003.15044.82190.stgit@ivy>
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
Received: from mx1.redhat.com ([209.132.183.28]:53006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbbEUKLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:11:50 -0400
In-Reply-To: <20150521101003.15044.82190.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And cleanup some whitespaces in pktgen.txt.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 0 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 747facc..62f5ebb 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -1,6 +1,6 @@
 
 
-                  HOWTO for the linux packet generator 
+                  HOWTO for the linux packet generator
                   ------------------------------------
 
 Enable CONFIG_NET_PKTGEN to compile and build pktgen either in-kernel
@@ -52,11 +52,10 @@ For ixgbe use e.g. "30" resulting in approx 33K interrupts/sec (1/30*10^6):
 
 Viewing threads
 ===============
-/proc/net/pktgen/kpktgend_0 
-Name: kpktgend_0  max_before_softirq: 10000
-Running: 
-Stopped: eth1 
-Result: OK: max_before_softirq=10000
+/proc/net/pktgen/kpktgend_0
+Running:
+Stopped: eth1
+Result: OK: add_device=eth1
 
 Most important are the devices assigned to the thread.  Note that a
 device can only belong to one thread.
@@ -69,7 +68,7 @@ The Params section holds configured information.  The Current section
 holds running statistics.  The Result is printed after a run or after
 interruption.  Example:
 
-/proc/net/pktgen/eth1       
+/proc/net/pktgen/eth1
 
 Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
      frags: 0  delay: 0  clone_skb: 1000000  ifname: eth1
@@ -126,7 +125,7 @@ Examples:
                          To select queue 1 of a given device,
                          use queue_map_min=1 and queue_map_max=1
 
- pgset "src_mac_count 1" Sets the number of MACs we'll range through.  
+ pgset "src_mac_count 1" Sets the number of MACs we'll range through.
                          The 'minimum' MAC is what you set with srcmac.
 
  pgset "dst_mac_count 1" Sets the number of MACs we'll range through.
@@ -247,7 +246,6 @@ stop
 
 add_device
 rem_device_all
-max_before_softirq
 
 
 ** Device commands:
@@ -262,7 +260,7 @@ delay
 src_mac_count
 dst_mac_count
 
-pkt_size 
+pkt_size
 min_pkt_size
 max_pkt_size
 
