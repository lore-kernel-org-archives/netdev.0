From: Marcus Better <marcus@better.se>
Subject: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 30 Jun 2006 11:23:05 +0200
Message-ID: <e82qhq$4v0$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:6576 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751601AbWF3JXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:23:31 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FwFDj-0005C2-UB
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 11:23:27 +0200
Received: from 67.152.216.81.static.g-va.siw.siwnet.net ([81.216.152.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 11:23:27 +0200
Received: from marcus by 67.152.216.81.static.g-va.siw.siwnet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 11:23:27 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm seeing this problem on my Acer Travelmate 223X laptop with built-in
Realtek 8139: The ethernet stops working, usually after at most a few
minutes operation. The problem appears in kernel 2.6.16 and 2.6.17, but not
in 2.6.15.

It prints the following in the syslog:

Jun 28 07:50:36 kelev kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 28 07:50:39 kelev kernel: eth0: link up, 100Mbps, half-duplex, lpa
0x40A1
Jun 28 07:50:51 kelev kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 28 07:50:54 kelev kernel: eth0: link up, 100Mbps, half-duplex, lpa
0x40A1
Jun 28 07:51:06 kelev kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 28 07:51:09 kelev kernel: eth0: link up, 100Mbps, half-duplex, lpa
0x40A1
Jun 28 07:51:21 kelev kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 28 07:51:24 kelev kernel: eth0: link up, 100Mbps, half-duplex, lpa
0x40A1

I've exchanged the hub and network cables, to no avail.

Results of lspci -vvv:

01:05.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RT8139
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns min, 16000ns max)
        Interrupt: pin A routed to IRQ 11
        Region 0: I/O ports at 9000 [size=256]
        Region 1: Memory at a0100000 (32-bit, non-prefetchable) [size=512]
        Capabilities: [60] Vital Product Data


Marcus


