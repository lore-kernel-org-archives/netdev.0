From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [REGRESSION] e1000e stopped working
Date: Sun, 27 Jun 2010 20:29:45 +0300
Message-ID: <1277659785.4028.1.camel@localhost.localdomain>
References: <1277659633.2989.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37137 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab0F0R3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 13:29:50 -0400
Received: by bwz10 with SMTP id 10so430355bwz.19
        for <netdev@vger.kernel.org>; Sun, 27 Jun 2010 10:29:48 -0700 (PDT)
In-Reply-To: <1277659633.2989.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-27 at 20:27 +0300, Maxim Levitsky wrote:
> Just that,
> 
> It doesn't receive anything from my internet router during DHCP.
> 
> 
> 00:19.0 Ethernet controller [0200]: Intel Corporation 82566DC Gigabit Network Connection [8086:104b] (rev 02)
> 	Subsystem: Intel Corporation Device [8086:0001]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 47
> 	Region 0: Memory at 50300000 (32-bit, non-prefetchable) [size=128K]
> 	Region 1: Memory at 50324000 (32-bit, non-prefetchable) [size=4K]
> 	Region 2: I/O ports at 30e0 [size=32]
> 	Capabilities: [c8] Power Management version 2
> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
> 		Address: 00000000fee0100c  Data: 41c9
> 	Kernel driver in use: e1000e
> 	Kernel modules: e1000e
> 
> I use vanilla tree, commit bf2937695fe2330bfd8933a2310e7bdd2581dc2e
> 
> 
> Best regards,
> 	Maxim Levitsky
> 

It appears to work now after reboot.
Will keep a look for this.

Disregard for now.

Best regards,
	Maxim Levitsky

