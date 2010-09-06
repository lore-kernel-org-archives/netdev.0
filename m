From: Priit Laes <plaes@plaes.org>
Subject: REGRESSION: e1000e fails to communicate (82566DM)
Date: Mon, 06 Sep 2010 23:51:44 +0300
Message-ID: <1283806304.6947.13.camel@chi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.store20.com ([212.7.7.16]:51037 "EHLO store20.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab0IFU7o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:59:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Heya!

After trying out newer 2.6.35-rc3 kernel, the network interface fails to
communicate (via dhcp and manual IP setup).

This seems to be a regression since 2.6.34-rc5:

lspci:

00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)
	Subsystem: Intel Corporation Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 31
	Region 0: Memory at 90300000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at 90324000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at 20e0 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41c9
	Kernel driver in use: e1000e

ethtool:
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: off
	Supports Wake-on: pumbag
	Wake-on: g
	Current message level: 0x00000001 (1)
			       drv
	Link detected: yes

