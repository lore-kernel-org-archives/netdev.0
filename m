From: Jike Song <albcamus@gmail.com>
Subject: [questions] why doesn't BCM5788 driver use MSI? What should I do to
	enable it?
Date: Wed, 21 Jan 2009 16:49:21 +0800
Message-ID: <df9815e70901210049j75979a1cm702a4da15e54a3e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:19198 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763594AbZAUItX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 03:49:23 -0500
Received: by ti-out-0910.google.com with SMTP id b6so2809499tic.23
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 00:49:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there any method to get BCM5788 (tg3 driver) work with MSI enabled?
lspci tells me MSI is supported by BCM5788 card:

$ sudo lspci -vvv -d 0x14e4:0x169c
02:01.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5788
Gigabit Ethernet (rev 03)
	Subsystem: Hewlett-Packard Company Device 30b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at d4000000 (32-bit, non-prefetchable) [size=64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
pcilib: sysfs_read_vpd: read failed: Connection timed out
		Not readable
	Capabilities: [58] MSI: Mask- 64bit+ Count=1/8 Enable-
		Address: bfdfb567bfff7ff8  Data: ffff
	Kernel driver in use: tg3
	Kernel modules: tg3

-- 
Thanks,
Jike
