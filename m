From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7450] New: e1000: eth0: e1000_clean_tx_irq:
 Detected Tx Unit Hang
Date: Thu, 2 Nov 2006 11:20:15 -0800
Message-ID: <20061102112015.d4f5c60e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pstaszewski@artcom.pl,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19339 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752320AbWKBTUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 14:20:34 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 2 Nov 2006 06:41:04 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7450] New: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang


http://bugzilla.kernel.org/show_bug.cgi?id=7450

           Summary: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
    Kernel Version: 2.6.19-rc3
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: pstaszewski@artcom.pl


Most recent kernel where this bug did not occur: not known
Distribution: Gentoo Linux x86_64
Hardware Environment: 
lspci
00:00.0 Host bridge: Intel Corporation E7230/3000/3010 Memory Controller Hub
(rev c0)
00:01.0 PCI bridge: Intel Corporation E7230/3000/3010 PCI Express Root Port (rev c0)
00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1
(rev 01)
00:1c.4 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express
Port 5 (rev 01)
00:1c.5 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express
Port 6 (rev 01)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1)
00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface
Bridge (rev 01)
00:1f.2 SATA controller: Intel Corporation 82801GR/GH (ICH7 Family) Serial ATA
Storage Controller AHCI (rev 01)
00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
01:00.0 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge A (rev 09)
01:00.1 PIC: Intel Corporation 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09)
01:00.2 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge B (rev 09)
01:00.3 PIC: Intel Corporation 6700PXH I/OxAPIC Interrupt Controller B (rev 09)
0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet
Controller (Copper) (rev 03)
0e:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
0f:04.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)

Software Environment: Iptables/Iproute2

Problem Description:
e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <31>
  TDT                  <31>
  next_to_use          <31>
  next_to_clean        <af>
buffer_info[next_to_clean]
  time_stamp           <1014b175c>
  next_to_watch        <af>
  jiffies              <1014b1875>
  next_to_watch.status <1>
e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <36>
  TDT                  <36>
  next_to_use          <36>
  next_to_clean        <b8>
buffer_info[next_to_clean]
  time_stamp           <1014b1922>
  next_to_watch        <b9>
  jiffies              <1014b1a7c>
  next_to_watch.status <1>
e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <fa>
  TDT                  <fa>
  next_to_use          <fa>
  next_to_clean        <7f>
buffer_info[next_to_clean]
  time_stamp           <1014b194b>
  next_to_watch        <80>
  jiffies              <1014b1ae0>
  next_to_watch.status <1>
printk: 423 messages suppressed.
dst cache overflow
e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <cf>
  TDT                  <cf>
  next_to_use          <cf>
  next_to_clean        <56>
buffer_info[next_to_clean]
  time_stamp           <1014b1bb7>
  next_to_watch        <57>
  jiffies              <1014b1cc9>
  next_to_watch.status <1>
e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <8c>
  TDT                  <8c>
  next_to_use          <8c>
  next_to_clean        <fe>
buffer_info[next_to_clean]
  time_stamp           <1014b1bef>
  next_to_watch        <fe>
  jiffies              <1014b1d86>
  next_to_watch.status <1>
e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <ee>
  TDT                  <ee>
  next_to_use          <ee>
  next_to_clean        <59>
buffer_info[next_to_clean]
  time_stamp           <1014b1ddd>
  next_to_watch        <59>
  jiffies              <1014b1fb6>
  next_to_watch.status <1>

0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet
Controller (Copper) (rev 03)
        Subsystem: Super Micro Computer Inc Unknown device 108c
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size 10
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at e0200000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 4000 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <512ns, L1 <64us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
                Link: Latency L0s <128ns, L1 <64us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x1

0e:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
        Subsystem: Super Micro Computer Inc Unknown device 109a
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size 10
        Interrupt: pin A routed to IRQ 17
        Region 0: Memory at e0300000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 5000 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <512ns, L1 <64us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
                Link: Latency L0s <128ns, L1 <64us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x1


ethtool -e eth0
Offset          Values
------          ------
0x0000          00 30 48 89 d1 b2 30 0d 46 f7 f4 00 ff ff ff ff
0x0010          ff ff ff ff 6b 02 8c 10 d9 15 8c 10 86 80 de 83
0x0020          08 00 00 20 14 7e 48 00 00 10 d8 00 00 00 00 27
0x0030          c9 6c 50 31 22 07 0b 04 84 09 00 00 00 c0 06 07
0x0040          08 10 00 00 04 0f ff 7f 01 4d ff ff ff ff ff ff
0x0050          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0060          00 01 00 40 1c 12 ff ff ff ff ff ff ff ff ff ff
0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff 5e 7c
0x0080          0a 00 00 0a 00 07 e9 03 33 c2 02 6f 02 98 00 00
0x0090          00 00 00 00 00 00 00 00 00 23 20 00 05 00 00 00
0x00a0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x00b0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x00c0          80 00 00 00 00 00 ff ff ff ff ff ff ff ff ff ff
0x00d0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x00e0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x00f0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0100          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0110          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0120          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0130          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0140          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0150          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0160          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0170          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0180          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0190          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x01a0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x01b0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x01c0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x01d0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x01e0          00 00 00 00 20 00 00 20 c9 00 00 00 00 00 00 fd
0x01f0          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0200          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0210          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0220          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0230          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0240          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0250          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0260          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0270          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0280          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0290          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x02a0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x02b0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x02c0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x02d0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x02e0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x02f0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0300          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0310          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0320          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0330          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0340          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0350          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0360          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0370          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0380          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x0390          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x03a0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x03b0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x03c0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x03d0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x03e0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
0x03f0          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
