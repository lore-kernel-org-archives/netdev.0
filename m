From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: Unable to get link beat with Niagara 2264 (Intel 82571EB) and
 e1000e driver on 3.4.4 (long)
Date: Thu, 2 Aug 2012 00:18:33 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89130D7FB34@ORSMSX102.amr.corp.intel.com>
References: <5019ABA3.4080506@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "kakadu08@comcast.net" <kakadu08@comcast.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39817 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab2HBASf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 20:18:35 -0400
In-Reply-To: <5019ABA3.4080506@comcast.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Bradley Chapman
>Sent: Wednesday, August 01, 2012 3:20 PM
>To: netdev@vger.kernel.org
>Subject: Unable to get link beat with Niagara 2264 (Intel 82571EB) and
>e1000e driver on 3.4.4 (long)
>
>All,
>
>(please CC me as I am not subscribed to netdev)
>
>I recently acquired an Interface Masters Niagara 2264 quad-port GigE
>network card, based on the Intel 82571EB network controller (see
>http://www.interfacemasters.com/products/2264.html for details). Prior to
>using it in a new system I'm planning to build I decided to try it out on
>my desktop system, which uses as Asus M4A89TD/PRO USB3 motherboard with
>the AMD 890FX chipset and a BIOS dated 03/08/2011, running Debian 6.0.2.1.
>
>I added the e1000e driver to my Linux 3.4.4 kernel config as a loadable
>module and inserted it, and got the following:
>
>e1000e: Intel(R) PRO/1000 Network Driver - 1.9.5-k
>e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
>e1000e 0000:06:00.0: Disabling ASPM  L1
>e1000e 0000:06:00.0: (unregistered net_device): Interrupt Throttling Rate
>(ints/sec) set to dynamic conservative mode e1000e 0000:06:00.0: irq 91
>for MSI/MSI-X e1000e 0000:06:00.0: eth1: (PCI Express:2.5GT/s:Width x4)
>00:0c:bd:01:cd:8c e1000e 0000:06:00.0: eth1: Intel(R) PRO/1000 Network
>Connection e1000e 0000:06:00.0: eth1: MAC: 0, PHY: 4, PBA No: C98149-002
>e1000e 0000:06:00.1: Disabling ASPM  L1 e1000e 0000:06:00.1: (unregistered
>net_device): Interrupt Throttling Rate (ints/sec) set to dynamic
>conservative mode e1000e 0000:06:00.1: irq 92 for MSI/MSI-X
>udev[1123]: renamed network interface eth1 to eth2 e1000e 0000:06:00.1:
>eth1: (PCI Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8d e1000e
>0000:06:00.1: eth1: Intel(R) PRO/1000 Network Connection e1000e
>0000:06:00.1: eth1: MAC: 0, PHY: 4, PBA No: C98149-002 e1000e
>0000:05:00.0: Disabling ASPM  L1 e1000e 0000:05:00.0: (unregistered
>net_device): Interrupt Throttling Rate (ints/sec) set to dynamic
>conservative mode e1000e 0000:05:00.0: irq 93 for MSI/MSI-X
>udev[8376]: renamed network interface eth1 to eth3 e1000e 0000:05:00.0:
>eth1: (PCI Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8a e1000e
>0000:05:00.0: eth1: Intel(R) PRO/1000 Network Connection e1000e
>0000:05:00.0: eth1: MAC: 0, PHY: 4, PBA No: C98149-002 e1000e
>0000:05:00.1: Disabling ASPM  L1 e1000e 0000:05:00.1: (unregistered
>net_device): Interrupt Throttling Rate (ints/sec) set to dynamic
>conservative mode e1000e 0000:05:00.1: irq 94 for MSI/MSI-X
>udev[8400]: renamed network interface eth1 to eth4 e1000e 0000:05:00.1:
>eth1: (PCI Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8b e1000e
>0000:05:00.1: eth1: Intel(R) PRO/1000 Network Connection e1000e
>0000:05:00.1: eth1: MAC: 0, PHY: 4, PBA No: C98149-002
>udev[8429]: renamed network interface eth1 to eth5

What is the link partner?
Have you tried connecting device to different link partners?

-Tushar
>
>After doing so, though, I was unable to get a link beat on any of the four
>RJ45 ports. I tried the Intel-supplied e1000e driver on the same kernel
>and got the following:
>
>e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0.1-NAPI
>e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
>e1000e 0000:06:00.0: Disabling ASPM  L1
>e1000e 0000:06:00.0: irq 91 for MSI/MSI-X e1000e 0000:06:00.0: eth1: (PCI
>Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8c e1000e 0000:06:00.0: eth1:
>Intel(R) PRO/1000 Network Connection e1000e 0000:06:00.0: eth1: MAC: 1,
>PHY: 4, PBA No: C98149-002 e1000e 0000:06:00.1: Disabling ASPM  L1 e1000e
>0000:06:00.1: irq 92 for MSI/MSI-X
>udev[8455]: renamed network interface eth1 to eth2 e1000e 0000:06:00.1:
>eth1: (PCI Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8d e1000e
>0000:06:00.1: eth1: Intel(R) PRO/1000 Network Connection e1000e
>0000:06:00.1: eth1: MAC: 1, PHY: 4, PBA No: C98149-002 e1000e
>0000:05:00.0: Disabling ASPM  L1 e1000e 0000:05:00.0: irq 93 for MSI/MSI-X
>udev[8455]: renamed network interface eth1 to eth3 e1000e 0000:05:00.0:
>eth1: (PCI Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8a e1000e
>0000:05:00.0: eth1: Intel(R) PRO/1000 Network Connection e1000e
>0000:05:00.0: eth1: MAC: 1, PHY: 4, PBA No: C98149-002 e1000e
>0000:05:00.1: Disabling ASPM  L1 e1000e 0000:05:00.1: irq 94 for MSI/MSI-X
>udev[8455]: renamed network interface eth1 to eth4 e1000e 0000:05:00.1:
>eth1: (PCI Express:2.5GT/s:Width x4) 00:0c:bd:01:cd:8b e1000e
>0000:05:00.1: eth1: Intel(R) PRO/1000 Network Connection e1000e
>0000:05:00.1: eth1: MAC: 1, PHY: 4, PBA No: C98149-002
>udev[8455]: renamed network interface eth1 to eth5
>
>ethtool -i and ethtool -d report the following for the Intel-supplied
>driver for one of the four interfaces exported to userspace:
>
>ethtool -i
>----------
>driver: e1000e
>version: 2.0.0.1-NAPI
>firmware-version: 5.0-2
>bus-info: 0000:06:00.0
>
>ethtool -d
>----------
>MAC Registers
>-------------
>0x00000: CTRL (Device control register)  0x40480241
>       Endian mode (buffers):             little
>       Link reset:                        normal
>       Set link up:                       1
>       Invert Loss-Of-Signal:             no
>       Receive flow control:              disabled
>       Transmit flow control:             disabled
>       VLAN mode:                         enabled
>       Auto speed detect:                 disabled
>       Speed select:                      1000Mb/s
>       Force speed:                       no
>       Force duplex:                      no
>0x00008: STATUS (Device status register) 0x00080380
>       Duplex:                            half
>       Link up:                           no link config
>       TBI mode:                          disabled
>       Link speed:                        1000Mb/s
>       Bus type:                          PCI Express
>       Port number:                       0
>0x00100: RCTL (Receive control register) 0x0400801A
>       Receiver:                          enabled
>       Store bad packets:                 disabled
>       Unicast promiscuous:               enabled
>       Multicast promiscuous:             enabled
>       Long packet:                       disabled
>       Descriptor minimum threshold size: 1/2
>       Broadcast accept mode:             accept
>       VLAN filter:                       disabled
>       Canonical form indicator:          disabled
>       Discard pause frames:              filtered
>       Pass MAC control frames:           don't pass
>       Receive buffer size:               2048
>0x02808: RDLEN (Receive desc length)     0x00001000
>0x02810: RDH   (Receive desc head)       0x00000000
>0x02818: RDT   (Receive desc tail)       0x000000F0
>0x02820: RDTR  (Receive delay timer)     0x00000020
>0x00400: TCTL (Transmit ctrl register)   0x3003F008
>       Transmitter:                       disabled
>       Pad short packets:                 enabled
>       Software XOFF Transmission:        disabled
>       Re-transmit on late collision:     disabled
>0x03808: TDLEN (Transmit desc length)    0x00001000
>0x03810: TDH   (Transmit desc head)      0x00000000
>0x03818: TDT   (Transmit desc tail)      0x00000000
>0x03820: TIDV  (Transmit delay timer)    0x00000008
>PHY type:                                unknown
>
>mii-diag -a reports the following:
>
>SIOCGMIIREG on eth2 failed: Input/output error Basic registers of MII PHY
>#1:  1140 7909 02a8 0380 0de1 0000 0004 ffff.
>  Basic mode control register 0x1140: Auto-negotiation enabled.
>  Basic mode status register 0x7909 ... 7909.
>    Link status: not established.
>    End of basic transceiver information.
>
>lspci reports the following:
>
>02:00.0 PCI bridge: PLX Technology, Inc. PEX 8517 16-lane, 5-port PCI
>Express Switch (rev ac)
>03:00.0 PCI bridge: PLX Technology, Inc. PEX 8517 16-lane, 5-port PCI
>Express Switch (rev ac)
>03:01.0 PCI bridge: PLX Technology, Inc. PEX 8517 16-lane, 5-port PCI
>Express Switch (rev ac)
>03:02.0 PCI bridge: PLX Technology, Inc. PEX 8517 16-lane, 5-port PCI
>Express Switch (rev ac)
>05:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (rev 06)
>05:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (rev 06)
>06:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (rev 06)
>06:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (rev 06)
>
>I tried rebooting since switching to the new driver and it hasn't made a
>difference. I did a bunch of digging in Google and couldn't find anything
>that conclusively suggested a problem - I found lots of stuff about BIOS
>bugs when dealing with ASPM, old regressions fixed in previous kernels,
>and so on, but nothing that specifically identified my problem.
>
>Does anyone have any suggestions? I can try Linux 3.5 very easily and if
>necessary I can also learn how to fetch a git tree and bisect it. I also
>sent an e-mail to the manufacturer asking for assistance with this device
>but I haven't received a response yet.
>
>Thanks,
>
>Brad
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in the
>body of a message to majordomo@vger.kernel.org More majordomo info at
>http://vger.kernel.org/majordomo-info.html
