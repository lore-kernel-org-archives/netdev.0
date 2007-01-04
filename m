From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Davicom Ethernet (onboard) with many Tx timeouts...
Date: Wed, 3 Jan 2007 22:33:08 -0200
Message-ID: <4jut64-6m7.ln1@tux.abusar.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:54948 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209AbXADAuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 19:50:11 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1H2Gnx-0004rF-Q6
	for netdev@vger.kernel.org; Thu, 04 Jan 2007 01:50:01 +0100
Received: from 200-207-206-233.dsl.telesp.net.br ([200.207.206.233])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 01:50:01 +0100
Received: from fragabr by 200-207-206-233.dsl.telesp.net.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 01:50:01 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux 2.6.19 (but this problem occurs with previous kernels too)
gcc 4.1.1
pentium 3
Module dmfe.ko

dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
eth0: Davicom DM9102 at pci0000:00:10.0, 00:d0:09:18:e1:8a, irq 5.

00:10.0 Ethernet controller: Davicom Semiconductor, Inc. Ethernet 100/10 MBit (rev 10)
        Subsystem: Unknown device 0291:8212
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR+
        Latency: 64 (5000ns min, 10000ns max)
        Interrupt: pin A routed to IRQ 5
        Region 0: I/O ports at d800 [size=128]
        Region 1: Memory at efffae80 (32-bit, non-prefetchable) [size=128]
        Expansion ROM at eff80000 [disabled] [size=256K]
        Capabilities: [50] Power Management version 1
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

eth0      Link encap:Ethernet  HWaddr 00:D0:09:18:E1:8A  
          inet addr:192.168.102.1  Bcast:192.168.102.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1892874 errors:1 dropped:0 overruns:1 frame:1
          TX packets:1611764 errors:1 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          Interrupt:5 Base address:0xd800 

	Everything works fine, except that I have too many kernel
warnings:

Jan  3 22:10:13 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:10:24 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:10:38 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:11:19 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:11:52 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:15:42 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:15:44 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:16:32 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:16:40 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:16:44 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:17:09 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:17:13 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:17:45 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:18:15 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:18:25 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:20:18 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:22:35 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:23:03 belforts vmunix: eth0: Tx timeout - resetting
Jan  3 22:23:30 belforts vmunix: eth0: Tx timeout - resetting

	and, of course, when this occurs, some packets are lost.

	How can I debug this to see if it's a dmfe module bug or a
hardware problem?

	Thank you very much!

-- 
http://u-br.net
Linux 2.6.19: Avast! A bilge rat!
Sao Paulo - SP

