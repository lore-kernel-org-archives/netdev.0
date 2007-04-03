From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: r8169 doesn't work
Date: Wed, 04 Apr 2007 06:03:36 +0900
Message-ID: <87ircdtbkn.fsf@duaron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.jp ([210.171.160.80]:3590 "EHLO parknet.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753658AbXDCVDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 17:03:45 -0400
Received: from ibmpc.myhome.or.jp ([210.171.168.39]:2238)
	by parknet.jp with [XMail 1.21 ESMTP Server]
	id <S11CFC> for <netdev@vger.kernel.org> from <hirofumi@mail.parknet.co.jp>;
	Wed, 4 Apr 2007 06:04:16 +0900
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have a r8169 problem, it seems RX doesn't work. To work r8169 for me
I'm needing to revert the following three commits now, but I don't
know why.

    9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2
    12d86f682e8acad8555718dc7b0082590f2365d0
    cc9f022d97d08e4e36d38661857991fe91447d68

Any idea?


02:03.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
	Subsystem: Micro-Star International Co., Ltd. Unknown device 210c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 128 bytes
	Interrupt: pin A routed to IRQ 20
	Region 0: I/O ports at c800 [size=256]
	Region 1: Memory at ff8ffc00 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at 60000000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: ec 10 69 81 17 00 b0 02 10 00 00 02 20 40 00 00
10: 01 c8 00 00 00 fc 8f ff 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 62 14 0c 21
30: 00 00 8c ff dc 00 00 00 00 00 00 00 05 01 20 40
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
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
