From: John Sigler <linux.kernel@free.fr>
Subject: 82557/8/9 Ethernet Pro 100 interrupt mitigation support
Date: Mon, 03 Sep 2007 12:36:03 +0200
Message-ID: <46DBE393.30300@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060301060402000502060103"
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060301060402000502060103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

(Please ignore previous message, it was sent from the wrong account.)

Hello everyone,

I have several systems with three integrated Intel 82559 (I *think*).

Does someone know if these boards support hardware interrupt mitigation?
I.e. is it possible to configure them to raise an IRQ only if their
hardware buffer is full OR if some given time (say 1 ms) has passed and
packets are available in their hardware buffer.

I've been using the eepro100 driver up to now, but I'm about to try the
e100 driver. Would I have to use NAPI? Or is this an orthogonal feature?

Regards.


--------------060301060402000502060103
Content-Type: text/plain;
 name="adlink.lspci"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="adlink.lspci"

00:08.0 Ethernet controller: Intel Corporation 82557/8/9 Ethernet Pro 100 (rev 08)
	Subsystem: Intel Corporation EtherExpress PRO/100B (TX)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at e6400000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at d800 [size=64]
	Region 2: Memory at e6100000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

00:09.0 Ethernet controller: Intel Corporation 82557/8/9 Ethernet Pro 100 (rev 08)
	Subsystem: Intel Corporation EtherExpress PRO/100B (TX)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at e6403000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at dc00 [size=64]
	Region 2: Memory at e6200000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

00:0a.0 Ethernet controller: Intel Corporation 82557/8/9 Ethernet Pro 100 (rev 08)
	Subsystem: Intel Corporation EtherExpress PRO/100B (TX)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 12
	Region 0: Memory at e6402000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at e000 [size=64]
	Region 2: Memory at e6000000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-


--------------060301060402000502060103--
