From: Frans Pop <elendil@planet.nl>
Subject: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Tue, 15 Jan 2008 06:25:10 +0100
Message-ID: <200801150625.10823.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752588AbYAOFZ2@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After compiling v2.6.24-rc7-163-g1a1b285 (x86_64) yesterday I suddenly see this error
repeatedly:
kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
kernel:   Tx Queue             <0>
kernel:   TDH                  <a>
kernel:   TDT                  <a>
kernel:   next_to_use          <a>
kernel:   next_to_clean        <ff>
kernel: buffer_info[next_to_clean]
kernel:   time_stamp           <10002738a>
kernel:   next_to_watch        <ff>
kernel:   jiffies              <1000275b4>
kernel:   next_to_watch.status <1>

My previous kernel was v2.6.24-rc7 and with that this error did not occur. I
have also never seen it with earlier kernels.

The values for "TX Queue" and "next_to_watch.status" are constant, the
others vary.

My NIC is:
01:00.0 Ethernet controller [0200]: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) (rev 03)

01:00.0 0200: 8086:108c (rev 03)
        Subsystem: 8086:3096
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 1273
        Region 0: Memory at 90200000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at 90100000 (32-bit, non-prefetchable) [size=1M]
        Region 2: I/O ports at 1000 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
                Address: 00000000fee0300c  Data: 41a9
        Capabilities: [e0] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <512ns, L1 <64us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
                Link: Latency L0s <128ns, L1 <64us
                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1

The system is an Intel D945GCZ main board with
Intel(R) Pentium(R) D CPU 3.20GHz (dual core) processor.

Cheers,
FJP
