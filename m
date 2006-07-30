From: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
Subject: IBM (Lenovo) T60: e1000 driver high latency
Date: Sun, 30 Jul 2006 23:57:32 +0200
Message-ID: <20060730215732.GA2576@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:21408 "EHLO
	faui03.informatik.uni-erlangen.de") by vger.kernel.org with ESMTP
	id S932468AbWG3V5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 17:57:34 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I recently aquired a Lenovo (IBM) T60 with a e1000 network card. I
experience high latency with this networkcard: Pings last upto 1 second
where the ping should be around 25 ms. I googled a bit and found the
following:

- Enable NAPI, which didn't worked for me.

        64 bytes from 192.168.0.223: icmp_seq=30 ttl=64 time=1004 ms
        64 bytes from 192.168.0.223: icmp_seq=31 ttl=64 time=0.444 ms
        64 bytes from 192.168.0.223: icmp_seq=32 ttl=64 time=1006 ms
        64 bytes from 192.168.0.223: icmp_seq=33 ttl=64 time=0.739 ms
        64 bytes from 192.168.0.223: icmp_seq=34 ttl=64 time=1006 ms
        64 bytes from 192.168.0.223: icmp_seq=35 ttl=64 time=0.603 ms
        64 bytes from 192.168.0.223: icmp_seq=36 ttl=64 time=1001 ms
        64 bytes from 192.168.0.223: icmp_seq=37 ttl=64 time=0.736 ms

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
        Subsystem: Lenovo Unknown device 2001
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 98
        Region 0: Memory at ee000000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 3000 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
                Address: 00000000fee00000  Data: 4062
        Capabilities: [e0] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <512ns, L1 <64us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
                Link: Latency L0s <128ns, L1 <64us
                Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 91-9c-58-ff-ff-41-16-00

Any ideas?

        Thomas
