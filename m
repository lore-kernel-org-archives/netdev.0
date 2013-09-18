From: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Subject: [REGRESSION][BISECTED] skge: add dma_mapping check
Date: Wed, 18 Sep 2013 13:00:44 +0400
Message-ID: <1379494844.2294.12.camel@ThinkPad-X230.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Mirko Lindner <mlindner@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 136d8f377e1575463b47840bc5f1b22d94bf8f63 commit we have kernel
panic on:
01:05.0 Ethernet controller [0200]: Marvell Technology Group Ltd.

Screen: https://www.dropbox.com/s/mu3t3wxpxbn4ou5/IMAG0507.jpg

RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1008323


01:05.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
88E8001 Gigabit Ethernet Controller [11ab:4320] (rev 13)
        Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabit
Ethernet Controller (Asus) [1043:811a]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 16 bytes
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at ddcfc000 (32-bit, non-prefetchable)
[size=16K]
        Region 1: I/O ports at a800 [size=256]
        Expansion ROM at ddcc0000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1
+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=7 DScale=1 PME-
        Capabilities: [50] Vital Product Data
                Product Name: Yukon Gigabit Ethernet 10/100/1000Base-T
Adapter
                Read-only fields:
                        [PN] Part number: Yukon 88E8001
                        [EC] Engineering changes: Rev. 1.3
                        [MN] Manufacture ID: 4d 61 72 76 65 6c 6c
                        [SN] Serial number: AbCdEfG000002
                        [CP] Extended capability: 01 10 cc 03
                        [RV] Reserved: checksum good, 10 byte(s)
reserved
                Read/write fields:
                        [RW] Read-write area: 121 byte(s) free
                End
        Kernel driver in use: skge

-- 
Igor Gnatenko
Fedora release 20 (Heisenbug)
Linux 3.11.1-300.fc20.x86_64
