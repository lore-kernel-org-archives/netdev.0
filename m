From: Krzysztof Oledzki <olel@ans.pl>
Subject: Upgradeing 2.6.21.7->2.6.22.9 kill my network (sky2): sky2 eth0: rx
 error, status 0x402300 length 60
Date: Fri, 28 Sep 2007 09:59:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709280950160.17152@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1683095180-1190966372=:17152"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:38713 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbXI1H7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 03:59:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1683095180-1190966372=:17152
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

After upgrading my kernel from 2.6.21.7 to 2.6.22.9 my 88E8053 no longer=20
works:

sky2 0000:02:00.0: v1.14 addr 0xcfffc000 irq 17 Yukon-EC (0xb6) rev 1
sky2 eth0: addr 00:11:d8:50:f6:28
sky2 eth0: enabling interface
sky2 eth0: ram buffer 48K
sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
sky2 eth0: rx error, status 0x402300 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402300 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402300 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402300 length 60
sky2 eth0: rx error, status 0x402300 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402300 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402500 length 60
sky2 eth0: rx error, status 0x402500 length 60
(...)

I also compared lspci output from both 2.6.21/2.6.22 and it is the same:

02:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd. 88E8053 P=
CI-E Gigabit Ethernet Controller [11ab:4362] (rev 15)
         Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet =
controller PCIe (Asus) [1043:8142]
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
- Stepping- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <=
TAbort- <MAbort- >SERR- <PERR-
         Latency: 0, Cache Line Size: 16 bytes
         Interrupt: pin A routed to IRQ 221
         Region 0: Memory at cfffc000 (64-bit, non-prefetchable) [size=3D16=
K]
         Region 2: I/O ports at d800 [size=3D256]
         Expansion ROM at cffc0000 [disabled] [size=3D128K]
         Capabilities: [48] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D=
2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
         Capabilities: [50] Vital Product Data
         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queu=
e=3D0/1 Enable+
                 Address: 00000000fee0300c  Data: 41c9
         Capabilities: [e0] Express Legacy Endpoint IRQ 0
                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtT=
ag-
                 Device: Latency L0s unlimited, L1 unlimited
                 Device: AtnBtn- AtnInd- PwrInd-
                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported=
-
                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr+ NoSnoop-
                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
                 Link: Latency L0s <256ns, L1 unlimited
                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
                 Link: Speed 2.5Gb/s, Width x1
00: ab 11 62 43 07 04 10 00 15 00 00 02 04 00 00 00
10: 04 c0 ff cf 00 00 00 00 01 d8 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 42 81
30: 00 00 fc cf 48 00 00 00 00 00 00 00 0a 01 00 00
40: 00 00 f0 01 00 80 a0 01 01 50 02 fe 00 20 00 14
50: 03 5c 00 80 00 00 00 01 00 00 00 01 05 e0 83 00
60: 0c 30 e0 fe 00 00 00 00 c9 41 00 00 00 00 00 00
70: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 10 00 11 00 c0 0f 00 00 00 24 1b 00 11 a4 03 00
f0: 08 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00


It is quite strange as on the other similar system (only rev 1/2=20
difference), sky2 driver from this 2.6.22 kernel solved my problem=20
(network hangs):

sky2 0000:03:00.0: v1.14 addr 0xf1000000 irq 16 Yukon-EC (0xb6) rev 2
sky2 eth0: addr 00:16:e6:5f:64:24
sky2 eth0: enabling interface
sky2 eth0: ram buffer 48K
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1683095180-1190966372=:17152--
