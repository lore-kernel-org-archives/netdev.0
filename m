From: Peter Missel <peter.missel@onlinehome.de>
Subject: r8169 2.2LK: Low link speed after suspend
Date: Mon, 16 Apr 2007 22:41:31 +0200
Message-ID: <200704162241.31729.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:52817 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586AbXDPUle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 16:41:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings!

I have a SuSE 10.2 64-bit installation that uses a Realtek PCI GbE chip in 
D-Link disguise (lspci see below).

While this works rather well after a normal boot sequence, I don't get a 
gigabit link after resume from standby or suspend-to-disk.

Entering standby, the link speed goes down to 100 Mb as expected; the link 
stays up during standby/suspend (for WOL purposes apparently).

Now after resume, the link is working OK but doesn't come back up to normal 
gigabit operation. ifdown, unloading and reloading the r8169 module, and then 
ifup again fixes it.

If there's something more I can do to help debug this, please let me know. 
Please be sure to copy me, since my list traffic here is still somewhat 
unreliable. Thanks.

regards,
Peter

00:0d.0 Ethernet controller: D-Link System Inc DGE-528T Gigabit Ethernet 
Adapter (rev 10)
	Subsystem: D-Link System Inc DGE-528T Gigabit Ethernet Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 185
	Region 0: I/O ports at eb00 [size=256]
	Region 1: Memory at e812c000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 50020000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 86 11 00 43 17 00 b0 02 10 00 00 02 10 20 00 00
10: 01 eb 00 00 00 c0 12 e8 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 11 00 43
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 20 40
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 c2 f7
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
