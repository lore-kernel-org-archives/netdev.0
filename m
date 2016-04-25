From: Eric Engestrom <eric@engestrom.ch>
Subject: [PATCH 30/41] Documentation: networking: fix spelling mistakes
Date: Mon, 25 Apr 2016 07:36:56 +0100
Message-ID: <1461566229-4717-4-git-send-email-eric@engestrom.ch>
References: <1461543878-3639-1-git-send-email-eric@engestrom.ch>
 <1461566229-4717-1-git-send-email-eric@engestrom.ch>
Cc: Eric Engestrom <eric@engestrom.ch>,
	Jonathan Corbet <corbet@lwn.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461566229-4717-1-git-send-email-eric@engestrom.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Eric Engestrom <eric@engestrom.ch>
---
 Documentation/networking/altera_tse.txt | 6 +++---
 Documentation/networking/ipvlan.txt     | 6 +++---
 Documentation/networking/pktgen.txt     | 6 +++---
 Documentation/networking/vrf.txt        | 2 +-
 Documentation/networking/xfrm_sync.txt  | 6 +++---
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/altera_tse.txt b/Documentation/networking/altera_tse.txt
index 3f24df8..50b8589 100644
--- a/Documentation/networking/altera_tse.txt
+++ b/Documentation/networking/altera_tse.txt
@@ -6,7 +6,7 @@ This is the driver for the Altera Triple-Speed Ethernet (TSE) controllers
 using the SGDMA and MSGDMA soft DMA IP components. The driver uses the
 platform bus to obtain component resources. The designs used to test this
 driver were built for a Cyclone(R) V SOC FPGA board, a Cyclone(R) V FPGA board,
-and tested with ARM and NIOS processor hosts seperately. The anticipated use
+and tested with ARM and NIOS processor hosts separately. The anticipated use
 cases are simple communications between an embedded system and an external peer
 for status and simple configuration of the embedded system.
 
@@ -65,14 +65,14 @@ Driver parameters can be also passed in command line by using:
 4.1) Transmit process
 When the driver's transmit routine is called by the kernel, it sets up a
 transmit descriptor by calling the underlying DMA transmit routine (SGDMA or
-MSGDMA), and initites a transmit operation. Once the transmit is complete, an
+MSGDMA), and initiates a transmit operation. Once the transmit is complete, an
 interrupt is driven by the transmit DMA logic. The driver handles the transmit
 completion in the context of the interrupt handling chain by recycling
 resource required to send and track the requested transmit operation.
 
 4.2) Receive process
 The driver will post receive buffers to the receive DMA logic during driver
-intialization. Receive buffers may or may not be queued depending upon the
+initialization. Receive buffers may or may not be queued depending upon the
 underlying DMA logic (MSGDMA is able queue receive buffers, SGDMA is not able
 to queue receive buffers to the SGDMA receive logic). When a packet is
 received, the DMA logic generates an interrupt. The driver handles a receive
diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
index cf99639..14422f8 100644
--- a/Documentation/networking/ipvlan.txt
+++ b/Documentation/networking/ipvlan.txt
@@ -8,7 +8,7 @@ Initial Release:
 	This is conceptually very similar to the macvlan driver with one major
 exception of using L3 for mux-ing /demux-ing among slaves. This property makes
 the master device share the L2 with it's slave devices. I have developed this
-driver in conjuntion with network namespaces and not sure if there is use case
+driver in conjunction with network namespaces and not sure if there is use case
 outside of it.
 
 
@@ -42,7 +42,7 @@ out. In this mode the slaves will RX/TX multicast and broadcast (if applicable)
 as well.
 
 4.2 L3 mode:
-	In this mode TX processing upto L3 happens on the stack instance attached
+	In this mode TX processing up to L3 happens on the stack instance attached
 to the slave device and packets are switched to the stack instance of the
 master device for the L2 processing and routing from that instance will be
 used before packets are queued on the outbound device. In this mode the slaves
@@ -56,7 +56,7 @@ situations defines your use case then you can choose to use ipvlan -
 	(a) The Linux host that is connected to the external switch / router has
 policy configured that allows only one mac per port.
 	(b) No of virtual devices created on a master exceed the mac capacity and
-puts the NIC in promiscous mode and degraded performance is a concern.
+puts the NIC in promiscuous mode and degraded performance is a concern.
 	(c) If the slave device is to be put into the hostile / untrusted network
 namespace where L2 on the slave could be changed / misused.
 
diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index f4be85e..2c4e335 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -67,12 +67,12 @@ The two basic thread commands are:
  * add_device DEVICE@NAME -- adds a single device
  * rem_device_all         -- remove all associated devices
 
-When adding a device to a thread, a corrosponding procfile is created
+When adding a device to a thread, a corresponding procfile is created
 which is used for configuring this device. Thus, device names need to
 be unique.
 
 To support adding the same device to multiple threads, which is useful
-with multi queue NICs, a the device naming scheme is extended with "@":
+with multi queue NICs, the device naming scheme is extended with "@":
  device@something
 
 The part after "@" can be anything, but it is custom to use the thread
@@ -221,7 +221,7 @@ Sample scripts
 
 A collection of tutorial scripts and helpers for pktgen is in the
 samples/pktgen directory. The helper parameters.sh file support easy
-and consistant parameter parsing across the sample scripts.
+and consistent parameter parsing across the sample scripts.
 
 Usage example and help:
  ./pktgen_sample01_simple.sh -i eth4 -m 00:1B:21:3C:9D:F8 -d 192.168.8.2
diff --git a/Documentation/networking/vrf.txt b/Documentation/networking/vrf.txt
index d52aa10..5da679c 100644
--- a/Documentation/networking/vrf.txt
+++ b/Documentation/networking/vrf.txt
@@ -41,7 +41,7 @@ using an rx_handler which gives the impression that packets flow through
 the VRF device. Similarly on egress routing rules are used to send packets
 to the VRF device driver before getting sent out the actual interface. This
 allows tcpdump on a VRF device to capture all packets into and out of the
-VRF as a whole.[1] Similiarly, netfilter [2] and tc rules can be applied
+VRF as a whole.[1] Similarly, netfilter [2] and tc rules can be applied
 using the VRF device to specify rules that apply to the VRF domain as a whole.
 
 [1] Packets in the forwarded state do not flow through the device, so those
diff --git a/Documentation/networking/xfrm_sync.txt b/Documentation/networking/xfrm_sync.txt
index d7aac9d..8d88e0f 100644
--- a/Documentation/networking/xfrm_sync.txt
+++ b/Documentation/networking/xfrm_sync.txt
@@ -4,7 +4,7 @@ Krisztian <hidden@balabit.hu> and others and additional patches
 from Jamal <hadi@cyberus.ca>.
 
 The end goal for syncing is to be able to insert attributes + generate
-events so that the an SA can be safely moved from one machine to another
+events so that the SA can be safely moved from one machine to another
 for HA purposes.
 The idea is to synchronize the SA so that the takeover machine can do
 the processing of the SA as accurate as possible if it has access to it.
@@ -13,7 +13,7 @@ We already have the ability to generate SA add/del/upd events.
 These patches add ability to sync and have accurate lifetime byte (to
 ensure proper decay of SAs) and replay counters to avoid replay attacks
 with as minimal loss at failover time.
-This way a backup stays as closely uptodate as an active member.
+This way a backup stays as closely up-to-date as an active member.
 
 Because the above items change for every packet the SA receives,
 it is possible for a lot of the events to be generated.
@@ -163,7 +163,7 @@ If you have an SA that is getting hit by traffic in bursts such that
 there is a period where the timer threshold expires with no packets
 seen, then an odd behavior is seen as follows:
 The first packet arrival after a timer expiry will trigger a timeout
-aevent; i.e we dont wait for a timeout period or a packet threshold
+event; i.e we don't wait for a timeout period or a packet threshold
 to be reached. This is done for simplicity and efficiency reasons.
 
 -JHS
-- 
2.8.0
