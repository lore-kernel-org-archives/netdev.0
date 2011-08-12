From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 01/02] net: add missing entries to Documentation/networking/00-INDEX
Date: Thu, 11 Aug 2011 20:39:59 -0400
Message-ID: <4E44765F.7060709@google.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com> <4E418030.2010102@hp.com> <4E44752D.1080905@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4E44752D.1080905@google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A simple janitor duty patch that adds a one sentence overview to
00-INDEX for all files that lacked it.

- does not add entries for subdirectories
- does not modify existing entries.
---
 Documentation/networking/00-INDEX |  116 +++++++++++++++++++++++++++++++++++++
 1 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 4edd78d..811252b 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -1,13 +1,21 @@
 00-INDEX
 	- this file
+3c359.txt
+	- information on the 3Com TokenLink Velocity XL (3c5359) driver.
 3c505.txt
 	- information on the 3Com EtherLink Plus (3c505) driver.
+3c509.txt
+	- information on the 3Com Etherlink III Series Ethernet cards.
 6pack.txt
 	- info on the 6pack protocol, an alternative to KISS for AX.25
 DLINK.txt
 	- info on the D-Link DE-600/DE-620 parallel port pocket adapters
 PLIP.txt
 	- PLIP: The Parallel Line Internet Protocol device driver
+README.ipw2100
+	- README for the Intel PRO/Wireless 2100 driver.
+README.ipw2200
+	- README for the Intel PRO/Wireless 2915ABG and 2200BG driver.
 README.sb1000
 	- info on General Instrument/NextLevel SURFboard1000 cable modem.
 alias.txt
@@ -20,8 +28,12 @@ atm.txt
 	- info on where to get ATM programs and support for Linux.
 ax25.txt
 	- info on using AX.25 and NET/ROM code for Linux
+batman-adv.txt
+	- B.A.T.M.A.N routing protocol on top of layer 2 Ethernet Frames.
 baycom.txt
 	- info on the driver for Baycom style amateur radio modems
+bonding.txt
+	- Linux Ethernet Bonding Driver HOWTO: link aggregation in Linux.
 bridge.txt
 	- where to get user space programs for ethernet bridging with Linux.
 can.txt
@@ -34,32 +46,60 @@ cxacru.txt
 	- Conexant AccessRunner USB ADSL Modem
 cxacru-cf.py
 	- Conexant AccessRunner USB ADSL Modem configuration file parser
+cxgb.txt
+	- Release Notes for the Chelsio N210 Linux device driver.
+dccp.txt
+	- the Datagram Congestion Control Protocol (DCCP) (RFC 4340..42).
 de4x5.txt
 	- the Digital EtherWORKS DE4?? and DE5?? PCI Ethernet driver
 decnet.txt
 	- info on using the DECnet networking layer in Linux.
 depca.txt
 	- the Digital DEPCA/EtherWORKS DE1?? and DE2?? LANCE Ethernet driver
+dl2k.txt
+	- README for D-Link DL2000-based Gigabit Ethernet Adapters (dl2k.ko).
+dm9000.txt
+	- README for the Simtec DM9000 Network driver.
 dmfe.txt
 	- info on the Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver.
+dns_resolver.txt
+	- The DNS resolver module allows kernel servies to make DNS queries.
+driver.txt
+	- Softnet driver issues.
 e100.txt
 	- info on Intel's EtherExpress PRO/100 line of 10/100 boards
 e1000.txt
 	- info on Intel's E1000 line of gigabit ethernet boards
+e1000e.txt
+	- README for the Intel Gigabit Ethernet Driver (e1000e).
 eql.txt
 	- serial IP load balancing
 ewrk3.txt
 	- the Digital EtherWORKS 3 DE203/4/5 Ethernet driver
+fib_trie.txt
+	- Level Compressed Trie (LC-trie) notes: a structure for routing.
 filter.txt
 	- Linux Socket Filtering
 fore200e.txt
 	- FORE Systems PCA-200E/SBA-200E ATM NIC driver info.
 framerelay.txt
 	- info on using Frame Relay/Data Link Connection Identifier (DLCI).
+gen_stats.txt
+	- Generic networking statistics for netlink users.
+generic_hdlc.txt
+	- The generic High Level Data Link Control (HDLC) layer.
 generic_netlink.txt
 	- info on Generic Netlink
+gianfar.txt
+	- Gianfar Ethernet Driver.
 ieee802154.txt
 	- Linux IEEE 802.15.4 implementation, API and drivers
+ifenslave.c
+	- Configure network interfaces for parallel routing (bonding).
+igb.txt
+	- README for the Intel Gigabit Ethernet Driver (igb).
+igbvf.txt
+	- README for the Intel Gigabit Ethernet Driver (igbvf).
 ip-sysctl.txt
 	- /proc/sys/net/ipv4/* variables
 ip_dynaddr.txt
@@ -68,41 +108,117 @@ ipddp.txt
 	- AppleTalk-IP Decapsulation and AppleTalk-IP Encapsulation
 iphase.txt
 	- Interphase PCI ATM (i)Chip IA Linux driver info.
+ipv6.txt
+	- Options to the ipv6 kernel module.
+ipvs-sysctl.txt
+	- Per-inode explanation of the /proc/sys/net/ipv4/vs interface.
 irda.txt
 	- where to get IrDA (infrared) utilities and info for Linux.
+ixgb.txt
+	- README for the Intel 10 Gigabit Ethernet Driver (ixgb).
+ixgbe.txt
+	- README for the Intel 10 Gigabit Ethernet Driver (ixgbe).
+ixgbevf.txt
+	- README for the Intel Virtual Function (VF) Driver (ixgbevf).
+l2tp.txt
+	- User guide to the L2TP tunnel protocol.
 lapb-module.txt
 	- programming information of the LAPB module.
 ltpc.txt
 	- the Apple or Farallon LocalTalk PC card driver
+mac80211-injection.txt
+	- HOWTO use packet injection with mac80211
 multicast.txt
 	- Behaviour of cards under Multicast
+multiqueue.txt
+	- HOWTO for multiqueue network device support.
+netconsole.txt
+	- The network console module netconsole.ko: configuration and notes.
+netdev-features.txt
+	- Network interface "feature mess and how to get out from it alive".
 netdevices.txt
 	- info on network device driver functions exported to the kernel.
+netif-msg.txt
+	- Design of the network interface message level setting (NETIF_MSG_*).
+nfc.txt
+	- The Linux Near Field Communication (NFS) subsystem.
 olympic.txt
 	- IBM PCI Pit/Pit-Phy/Olympic Token Ring driver info.
+operstates.txt
+	- Overview of network interface operational states.
+packet_mmap.txt
+	- User guide to memory mapped packet socket rings (PACKET_[RT]X_RING).
+phonet.txt
+	- The Phonet packet protocol used in Nokia cellular modems.
+phy.txt
+	- The PHY abstraction layer.
+pktgen.txt
+	- User guide to the kernel packet generator (pktgen.ko).
 policy-routing.txt
 	- IP policy-based routing
+ppp_generic.txt
+	- Information about the generic PPP driver.
+proc_net_tcp.txt
+	- Per inode overview of the /proc/net/tcp and /proc/net/tcp6 interfaces.
+radiotap-headers.txt
+	- Background on radiotap headers.
 ray_cs.txt
 	- Raylink Wireless LAN card driver info.
+rds.txt
+	- Background on the reliable, ordered datagram delivery method RDS.
+regulatory.txt
+	- Overview of the Linux wireless regulatory infrastructure.
+rxrpc.txt
+	- Guide to the RxRPC protocol.
+s2io.txt
+	- Release notes for Neterion Xframe I/II 10GbE driver.
+scaling.txt
+	- Explanation of network scaling techniques: RSS, RPS, RFS, aRFS, XPS.
+sctp.txt
+	- Notes on the Linux kernel implementation of the SCTP protocol.
+secid.txt
+	- Explanation of the secid member in flow structures.
 skfp.txt
 	- SysKonnect FDDI (SK-5xxx, Compaq Netelligent) driver info.
 smc9.txt
 	- the driver for SMC's 9000 series of Ethernet cards
 smctr.txt
 	- SMC TokenCard TokenRing Linux driver info.
+spider-net.txt
+	- README for the Spidernet Driver (as found in PS3 / Cell BE).
+stmmac.txt
+	- README for the STMicro Synopsys Ethernet driver.
+tc-actions-env-rules.txt
+	- rules for traffic control (tc) actions.
+timestamping.txt
+	- overview of network packet timestamping variants.
 tcp.txt
 	- short blurb on how TCP output takes place.
+tcp-thin.txt
+	- kernel tuning options for low rate 'thin' TCP streams.
 tlan.txt
 	- ThunderLAN (Compaq Netelligent 10/100, Olicom OC-2xxx) driver info.
 tms380tr.txt
 	- SysKonnect Token Ring ISA/PCI adapter driver info.
+tproxy.txt
+	- Transparent proxy support user guide.
 tuntap.txt
 	- TUN/TAP device driver, allowing user space Rx/Tx of packets.
+udplite.txt
+	- UDP-Lite protocol (RFC 3828) introduction.
 vortex.txt
 	- info on using 3Com Vortex (3c590, 3c592, 3c595, 3c597) Ethernet cards.
+vxge.txt
+	- README for the Neterion X3100 PCIe Server Adapter.
 x25.txt
 	- general info on X.25 development.
 x25-iface.txt
 	- description of the X.25 Packet Layer to LAPB device interface.
+xfrm_proc.txt
+	- description of the statistics package for XFRM.
+xfrm_sync.txt
+	- sync patches for XFRM enable migration of an SA between hosts.
+xfrm_sysctl.txt
+	- description of the XFRM configuration options.
 z8530drv.txt
 	- info about Linux driver for Z8530 based HDLC cards for AX.25
-- 
1.7.3.1
