From: =?ISO-8859-1?Q?John_B=E4ckstrand?= <sandos@home.se>
Subject: 2.6.16, 3com: transmit timed out, tx_status 00 status 8000
Date: Tue, 28 Mar 2006 01:25:06 +0200
Message-ID: <44287452.6030205@home.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ive been seeing stuff in dmesg with very recent kernels:

NETDEV WATCHDOG: 3com: transmit timed out
3com: transmit timed out, tx_status 00 status 8000.
   diagnostics: net 04fa media 8880 dma 000000a0 fifo 0000
   Flags; bus-master 1, dirty 67260778(10) current 67260794(10)
   Transmit list 2f6758e0 vs. ef675840.
3com: command 0x3002 did not complete! Status=3D0x9000
   0: @ef675200  length 80000036 status 00000036
   1: @ef6752a0  length 80000042 status 00000042
   2: @ef675340  length 8000028c status 0000028c
   3: @ef6753e0  length 800005d6 status 000005d6
   4: @ef675480  length 800005ea status 000005ea
   5: @ef675520  length 800005ba status 000005ba
   6: @ef6755c0  length 8000028c status 0000028c
   7: @ef675660  length 800005d6 status 000005d6
   8: @ef675700  length 800005ea status 800005ea
   9: @ef6757a0  length 800005d6 status 800005d6
   10: @ef675840  length 80000036 status 00010036
   11: @ef6758e0  length 80000036 status 00000036
   12: @ef675980  length 80000036 status 00000036
   13: @ef675a20  length 80000036 status 00000036
   14: @ef675ac0  length 80000036 status 00000036
   15: @ef675b60  length 80000036 status 00000036

Any ideas at all? Seems to happen mostly when doing heavy downloading.

I think this did not happen a few versions ago, I know it happened with=
=20
2.6.16-rc6, and 2.6.16. I donk think it used to happen on .14/.15 and=20
earlier though.

The card is a 3c905.

0000:00:0b.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M=20
[Tornado] (rev 74)
         Subsystem: 3Com Corporation 3C905C-TX Fast Etherlink for PC=20
Management NIC
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-=20
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium=20
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (2500ns min, 2500ns max), Cache Line Size: 0x08 (3=
2=20
bytes)
         Interrupt: pin A routed to IRQ 10
         Region 0: I/O ports at 9000 [size=3D128]
         Region 1: Memory at e3000000 (32-bit, non-prefetchable) [size=3D=
128]
         Expansion ROM at 40000000 [disabled] [size=3D128K]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA=20
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=3D0 DScale=3D2 PME-

(I see there has been 3com-related patches in -git, should I try this?=20
Any chance of them helping?

---
John B=E4ckstrand
