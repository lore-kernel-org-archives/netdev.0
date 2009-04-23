From: Michael Di Domenico <mdidomenico4@gmail.com>
Subject: sis900 tx timeouts
Date: Thu, 23 Apr 2009 12:53:49 -0400
Message-ID: <e75d22a90904230953gf855de5j18fb8ee1aa6d5a85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:38618 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbZDWQxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 12:53:51 -0400
Received: by bwz7 with SMTP id 7so653126bwz.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 09:53:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have an Intel motherboard with an sis900 nic chipset down on the
board.  When i put the NIC under heavy send traffic i start to see
Transmit error's in dmesg and the nic stops sending data.  if i do an
ifdown eth0; ifup eth0 the nic starts responding again just fine and
will run for a while, but eventually the transmit errors return.  Can
anyone lend advice on how i might fix or help track down this error?

thanks

--- lspci -vvv
00:04.0 Ethernet controller: Silicon Integrated Systems [SiS] SiS900
PCI Fast Ethernet (rev 91)
	Subsystem: Intel Corporation Unknown device d61f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (13000ns min, 2750ns max)
	Interrupt: pin A routed to IRQ 225
	Region 0: I/O ports at 2000 [size=256]
	Region 1: Memory at 4a100000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at 4a120000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

--- dmesg
eth0: Transmit error, Tx status 060005ea.
eth0: Transmit error, Tx status 060005ea.

--- uname -a
Linux node5.home 2.6.18-92.1.17.el5_lustre.1.6.7.1smp #1 SMP Mon Apr
13 18:23:52 MDT 2009 i686 i686 i386 GNU/Linux
