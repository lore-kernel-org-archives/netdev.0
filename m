From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: bnx2 breaks Dell R815 BMC IPMI since 4.8
Date: Tue, 29 Nov 2016 07:57:51 +0100
Message-ID: <583D26EF.60207@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>,
        Baoquan He <bhe@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:1998 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756222AbcK2G5x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:57:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

My Dell PowerEdge R815 doesn't have IPMI anymore when I boot a 4.8
kernel, the BMC doesn't even ping anymore. Its Ethernet devices are 4 of
those:

01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	DeviceName: Embedded NIC 1                          
	Subsystem: Dell NetXtreme II BCM5709 Gigabit Ethernet
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 42
	Region 0: Memory at e6000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: <access denied>
	Kernel driver in use: bnx2
	Kernel modules: bnx2

The only change in bnx2 between 4.7 and 4.8 appears to be this one:

commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c
Author: Baoquan He <bhe@redhat.com>
Date:   Fri Sep 9 22:43:12 2016 +0800

    bnx2: Reset device during driver initialization

Could you patch actually break the BMC? What do I need to further debug
this issue?

Thanks
Brice
