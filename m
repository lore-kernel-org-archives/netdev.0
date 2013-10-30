From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial]doc:net: Fix typo in Documentation/networking
Date: Wed, 30 Oct 2013 16:46:15 +0900
Message-ID: <1383119175-1963-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, linux-kenrel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:48484 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab3J3HqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 03:46:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct spelling typo in Documentation/networking

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/networking/dccp.txt         | 4 ++--
 Documentation/networking/e100.txt         | 2 +-
 Documentation/networking/ieee802154.txt   | 4 ++--
 Documentation/networking/l2tp.txt         | 2 +-
 Documentation/networking/netdev-FAQ.txt   | 2 +-
 Documentation/networking/netlink_mmap.txt | 6 +++---
 Documentation/networking/operstates.txt   | 2 +-
 Documentation/networking/rxrpc.txt        | 2 +-
 Documentation/networking/stmmac.txt       | 8 ++++----
 Documentation/networking/vortex.txt       | 4 ++--
 Documentation/networking/x25-iface.txt    | 2 +-
 11 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index d718bc2..bf5dbe3 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -18,8 +18,8 @@ Introduction
 Datagram Congestion Control Protocol (DCCP) is an unreliable, connection
 oriented protocol designed to solve issues present in UDP and TCP, particularly
 for real-time and multimedia (streaming) traffic.
-It divides into a base protocol (RFC 4340) and plugable congestion control
-modules called CCIDs. Like plugable TCP congestion control, at least one CCID
+It divides into a base protocol (RFC 4340) and pluggable congestion control
+modules called CCIDs. Like pluggable TCP congestion control, at least one CCID
 needs to be enabled in order for the protocol to function properly. In the Linux
 implementation, this is the TCP-like CCID2 (RFC 4341). Additional CCIDs, such as
 the TCP-friendly CCID3 (RFC 4342), are optional.
diff --git a/Documentation/networking/e100.txt b/Documentation/networking/e100.txt
index 13a3212..f862cf3 100644
--- a/Documentation/networking/e100.txt
+++ b/Documentation/networking/e100.txt
@@ -103,7 +103,7 @@ Additional Configurations
   PRO/100 Family of Adapters is e100.
 
   As an example, if you install the e100 driver for two PRO/100 adapters
-  (eth0 and eth1), add the following to a configuraton file in /etc/modprobe.d/
+  (eth0 and eth1), add the following to a configuration file in /etc/modprobe.d/
 
        alias eth0 e100
        alias eth1 e100
diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 09eb573..98c8b2b 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -4,7 +4,7 @@
 
 Introduction
 ============
-The IEEE 802.15.4 working group focuses on standartization of bottom
+The IEEE 802.15.4 working group focuses on standardization of bottom
 two layers: Medium Access Control (MAC) and Physical (PHY). And there
 are mainly two options available for upper layers:
  - ZigBee - proprietary protocol from ZigBee Alliance
@@ -66,7 +66,7 @@ net_device, with .type = ARPHRD_IEEE802154. Data is exchanged with socket family
 code via plain sk_buffs. On skb reception skb->cb must contain additional
 info as described in the struct ieee802154_mac_cb. During packet transmission
 the skb->cb is used to provide additional data to device's header_ops->create
-function. Be aware, that this data can be overriden later (when socket code
+function. Be aware, that this data can be overridden later (when socket code
 submits skb to qdisc), so if you need something from that cb later, you should
 store info in the skb->data on your own.
 
diff --git a/Documentation/networking/l2tp.txt b/Documentation/networking/l2tp.txt
index e63fc1f..c74434d 100644
--- a/Documentation/networking/l2tp.txt
+++ b/Documentation/networking/l2tp.txt
@@ -197,7 +197,7 @@ state information because the file format is subject to change. It is
 implemented to provide extra debug information to help diagnose
 problems.) Users should use the netlink API.
 
-/proc/net/pppol2tp is also provided for backwards compaibility with
+/proc/net/pppol2tp is also provided for backwards compatibility with
 the original pppol2tp driver. It lists information about L2TPv2
 tunnels and sessions only. Its use is discouraged.
 
diff --git a/Documentation/networking/netdev-FAQ.txt b/Documentation/networking/netdev-FAQ.txt
index d9112f0..1eb763a 100644
--- a/Documentation/networking/netdev-FAQ.txt
+++ b/Documentation/networking/netdev-FAQ.txt
@@ -68,7 +68,7 @@ A: To understand this, you need to know a bit of background information
 
    The "net" tree continues to collect fixes for the vX.Y content, and
    is fed back to Linus at regular (~weekly) intervals.  Meaning that the
-   focus for "net" is on stablilization and bugfixes.
+   focus for "net" is on stabilization and bugfixes.
 
    Finally, the vX.Y gets released, and the whole cycle starts over.
 
diff --git a/Documentation/networking/netlink_mmap.txt b/Documentation/networking/netlink_mmap.txt
index 5333788..b261229 100644
--- a/Documentation/networking/netlink_mmap.txt
+++ b/Documentation/networking/netlink_mmap.txt
@@ -45,7 +45,7 @@ processing.
 
 Conversion of the reception path involves calling poll() on the file
 descriptor, once the socket is readable the frames from the ring are
-processsed in order until no more messages are available, as indicated by
+processed in order until no more messages are available, as indicated by
 a status word in the frame header.
 
 On kernel side, in order to make use of memory mapped I/O on receive, the
@@ -56,7 +56,7 @@ Dumps of kernel databases automatically support memory mapped I/O.
 
 Conversion of the transmit path involves changing message construction to
 use memory from the TX ring instead of (usually) a buffer declared on the
-stack and setting up the frame header approriately. Optionally poll() can
+stack and setting up the frame header appropriately. Optionally poll() can
 be used to wait for free frames in the TX ring.
 
 Structured and definitions for using memory mapped I/O are contained in
@@ -231,7 +231,7 @@ Ring setup:
 	if (setsockopt(fd, NETLINK_TX_RING, &req, sizeof(req)) < 0)
 		exit(1)
 
-	/* Calculate size of each invididual ring */
+	/* Calculate size of each individual ring */
 	ring_size = req.nm_block_nr * req.nm_block_size;
 
 	/* Map RX/TX rings. The TX ring is located after the RX ring */
diff --git a/Documentation/networking/operstates.txt b/Documentation/networking/operstates.txt
index 9769457..c40f4bb 100644
--- a/Documentation/networking/operstates.txt
+++ b/Documentation/networking/operstates.txt
@@ -89,7 +89,7 @@ packets. The name 'carrier' and the inversion are historical, think of
 it as lower layer.
 
 Note that for certain kind of soft-devices, which are not managing any
-real hardware, there is possible to set this bit from userpsace.
+real hardware, there is possible to set this bit from userspace.
 One should use TVL IFLA_CARRIER to do so.
 
 netif_carrier_ok() can be used to query that bit.
diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 60d05eb..b89bc82e 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -144,7 +144,7 @@ An overview of the RxRPC protocol:
  (*) Calls use ACK packets to handle reliability.  Data packets are also
      explicitly sequenced per call.
 
- (*) There are two types of positive acknowledgement: hard-ACKs and soft-ACKs.
+ (*) There are two types of positive acknowledgment: hard-ACKs and soft-ACKs.
      A hard-ACK indicates to the far side that all the data received to a point
      has been received and processed; a soft-ACK indicates that the data has
      been received but may yet be discarded and re-requested.  The sender may
diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 457b8bb..cdd916d 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -160,7 +160,7 @@ Where:
  o pmt: core has the embedded power module (optional).
  o force_sf_dma_mode: force DMA to use the Store and Forward mode
 		     instead of the Threshold.
- o force_thresh_dma_mode: force DMA to use the Shreshold mode other than
+ o force_thresh_dma_mode: force DMA to use the Threshold mode other than
 		     the Store and Forward mode.
  o riwt_off: force to disable the RX watchdog feature and switch to NAPI mode.
  o fix_mac_speed: this callback is used for modifying some syscfg registers
@@ -175,7 +175,7 @@ Where:
 	     registers.
  o custom_cfg/custom_data: this is a custom configuration that can be passed
 			   while initializing the resources.
- o bsp_priv: another private poiter.
+ o bsp_priv: another private pointer.
 
 For MDIO bus The we have:
 
@@ -271,7 +271,7 @@ reset procedure etc).
  o dwmac1000_dma.c:  dma functions for the GMAC chip;
  o dwmac1000.h: specific header file for the GMAC;
  o dwmac100_core: MAC 100 core and dma code;
- o dwmac100_dma.c: dma funtions for the MAC chip;
+ o dwmac100_dma.c: dma functions for the MAC chip;
  o dwmac1000.h: specific header file for the MAC;
  o dwmac_lib.c: generic DMA functions shared among chips;
  o enh_desc.c: functions for handling enhanced descriptors;
@@ -364,4 +364,4 @@ Auto-negotiated Link Parter Ability.
 10) TODO:
  o XGMAC is not supported.
  o Complete the TBI & RTBI support.
- o extened VLAN support for 3.70a SYNP GMAC.
+ o extend VLAN support for 3.70a SYNP GMAC.
diff --git a/Documentation/networking/vortex.txt b/Documentation/networking/vortex.txt
index 9a8041d..97282da 100644
--- a/Documentation/networking/vortex.txt
+++ b/Documentation/networking/vortex.txt
@@ -68,7 +68,7 @@ Module parameters
 
 There are several parameters which may be provided to the driver when
 its module is loaded.  These are usually placed in /etc/modprobe.d/*.conf
-configuretion files.  Example:
+configuration files.  Example:
 
 options 3c59x debug=3 rx_copybreak=300
 
@@ -178,7 +178,7 @@ max_interrupt_work=N
 
   The driver's interrupt service routine can handle many receive and
   transmit packets in a single invocation.  It does this in a loop. 
-  The value of max_interrupt_work governs how mnay times the interrupt
+  The value of max_interrupt_work governs how many times the interrupt
   service routine will loop.  The default value is 32 loops.  If this
   is exceeded the interrupt service routine gives up and generates a
   warning message "eth0: Too much work in interrupt".
diff --git a/Documentation/networking/x25-iface.txt b/Documentation/networking/x25-iface.txt
index 78f662e..7f213b5 100644
--- a/Documentation/networking/x25-iface.txt
+++ b/Documentation/networking/x25-iface.txt
@@ -105,7 +105,7 @@ reduced by the following measures or a combination thereof:
     later.
     The lapb module interface was modified to support this. Its
     data_indication() method should now transparently pass the
-    netif_rx() return value to the (lapb mopdule) caller.
+    netif_rx() return value to the (lapb module) caller.
 (2) Drivers for kernel versions 2.2.x should always check the global
     variable netdev_dropping when a new frame is received. The driver
     should only call netif_rx() if netdev_dropping is zero. Otherwise
-- 
1.8.4.1.600.g3d092bf
