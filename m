From: Abhijit Karmarkar <abhijitk@veritas.com>
Subject: unaligned ethernet payload in bcm5701?
Date: Fri, 28 May 2004 15:33:31 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.50.0405281516500.11510-100000@revati>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,

i am using tg3 driver (ver 2.2, part of RHEL3) with Broadcom GigE, 5701
chipset. and i see this particular chipset delivering ethernet frames w/
payloads not aligned at word (4 byte) boundaries. (though not always,
but occasionally). none of the other broadcom chips (BCM570[0|2|3|4])
deliver such unaligned pkts.

is something peculiar with the bcm5701? and is this a known issue with
this chipset?

thanks,
abhijit

Note:

1. sysinfo: Dell 2650, 2-way 2.5GHz Xeon, 4GB RAM. 2.4.21-4.ELsmp

2. the lspci -vv output for this card is:

03:06.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701
        Gigabit Ethernet (rev 15)
        Subsystem: Dell Computer Corporation Broadcom BCM5701 1000Base-T
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (16000ns min), cache line size 10
        Interrupt: pin A routed to IRQ 28
        Region 0: Memory at fcb10000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [40] PCI-X non-bridge device.
                Command: DPERE- ERO- RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-,DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-      Capabilities: [48]Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
                Address: ca9ee0227c6f3ac8  Data: cdfd
