From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: "skge 0000:01:0a.0: unsupported phy type 0x0"
Date: Mon, 5 Mar 2007 13:48:29 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703051346070.25740@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-1.smtp.ucla.edu ([169.232.46.136]:49142 "EHLO
	smtp-1.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933670AbXCEV4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 16:56:03 -0500
Received: from potato.cts.ucla.edu (potato.cts.ucla.edu [128.97.128.80])
	by smtp-1.smtp.ucla.edu (8.13.8/8.13.8) with ESMTP id l25LmTRu009825
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 13:48:29 -0800
Received: from potato.cts.ucla.edu (localhost [127.0.0.1])
	by potato.cts.ucla.edu (8.13.4/8.13.4/Debian-3sarge3) with ESMTP id l25LmTsx008268
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 13:48:29 -0800
Received: from localhost (cbs@localhost)
	by potato.cts.ucla.edu (8.13.4/8.13.4/Submit) with ESMTP id l25LmTLm008265
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 13:48:29 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a bunch of dual-port SK 98xx cards that work with sk98lin but not 
with skge.  After loading skge, I get

ACPI: PCI Interrupt 0000:01:0a.0[A] -> Link [LNKC] -> GSI 10 (level, low) -> IRQ 10
skge 0000:01:0a.0: unsupported phy type 0x0
ACPI: PCI interrupt for device 0000:01:0a.0 disabled
skge: probe of 0000:01:0a.0 failed with error -95


lspci -vv output for the card:

0000:01:0a.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx Gigabit Ethernet Server Adapter (rev 12)
         Subsystem: Syskonnect (Schneider & Koch) SK-9844 Gigabit Ethernet Server Adapter (SK-NET GE-SX dual link)
         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Interrupt: pin A routed to IRQ 10
         Region 0: Memory at ff8fc000 (32-bit, non-prefetchable) [size=16K]
         Region 1: I/O ports at d800 [size=256]
         Expansion ROM at ff400000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 1
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data




-Chris
