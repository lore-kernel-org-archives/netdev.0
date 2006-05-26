From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: Re: [PATCH] r8169: add new PCI ID
Date: Sat, 27 May 2006 05:24:14 +0900
Message-ID: <20060527052414.325e7d6f.yoichi_yuasa@tripeaks.co.jp>
References: <20060525102446.572bb5ca.yoichi_yuasa@tripeaks.co.jp>
	<4477AFAB.6050405@garzik.org>
	<20060527113919.GA1883@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo32.po.2iij.net ([210.128.50.17]:9033 "EHLO mo32.po.2iij.net")
	by vger.kernel.org with ESMTP id S1751519AbWE0Nn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 09:43:29 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060527113919.GA1883@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 27 May 2006 13:39:19 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Jeff Garzik <jeff@garzik.org> :
> [...]
> > applied
> 
> $ grep 8129 drivers/net/*.[ch]
> [...]
> drivers/net/8139too.c:  {0x10ec, 0x8129, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 }
> 
> Not a big issue but I would be really surprized that it does trigger
> a few PR.

me too, but it is true.
I have checked 2 chips of RTL8110SBL.
These chips work without any problem by the r8169 driver.

Yoichi

lspci result:
0000:01:02.0 0200: 10ec:8129 (rev 10)
	Subsystem: 11ec:8129
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 128 (8000ns min, 8000ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 53
	Region 0: I/O ports at 1000000 [size=256]
	Region 1: Memory at 11b00000 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at 11c00000 [disabled] [size=32K]
	Capabilities: [dc] Power Management version 6
		Flags: PMEClk+ DSI+ D1- D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME+

0000:01:03.0 0200: 10ec:8129 (rev 10)
	Subsystem: 11ec:8129
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 128 (8000ns min, 8000ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 53
	Region 0: I/O ports at 1000400 [size=256]
	Region 1: Memory at 11b00100 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at 11c08000 [disabled] [size=8K]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk+ DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2+,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
