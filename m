From: Stephen Hemminger <shemminger@osdl.org>
Subject: acenic: Unhandled event 0x24
Date: Tue, 29 Jun 2004 15:47:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629154751.20f4772a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the acenic gigabit ether card is under lots of receive pressure,
it generates many (not excessive) console output about
	Unhandled event 0x24

I presume this is because the receive ring is getting over run and
packet was dropped.

Board info:

[root@dev4-000 root]# lspci -v
00:00.0 Host bridge: ServerWorks CNB20HE Host Bridge (rev 21)
        Flags: fast devsel

00:00.1 Host bridge: ServerWorks CNB20HE Host Bridge (rev 01)
        Flags: bus master, medium devsel, latency 96

00:00.2 Host bridge: ServerWorks CNB20HE Host Bridge
        Flags: medium devsel

00:00.3 Host bridge: ServerWorks CNB20HE Host Bridge
        Flags: medium devsel

00:01.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
        Subsystem: Intel Corp. EtherExpress PRO/100+ Server Adapter (PILA8470B)
        Flags: bus master, medium devsel, latency 100, IRQ 20
        Memory at febff000 (32-bit, non-prefetchable)
        I/O ports at 2200 [size=64]
        Memory at fea00000 (32-bit, non-prefetchable) [size=1M]
        Capabilities: [dc] Power Management version 2

00:05.0 Ethernet controller: Advanced Micro Devices [AMD] 79c970 [PCnet32 LANCE] (rev 44)
        Subsystem: IBM NetFinity 10/100 Fast Ethernet
        Flags: bus master, medium devsel, latency 100, IRQ 16
        I/O ports at 2240
        Memory at febfec00 (32-bit, non-prefetchable) [size=32]
        Capabilities: [40] Power Management version 2

00:06.0 VGA compatible controller: S3 Inc. Savage 4 (rev 04) (prog-if 00 [VGA])
        Subsystem: IBM: Unknown device 01c5
        Flags: bus master, medium devsel, latency 248, IRQ 18
        Memory at feb00000 (32-bit, non-prefetchable)
        Memory at f0000000 (32-bit, prefetchable) [size=128M]
        Capabilities: [dc] Power Management version 1

00:0f.0 ISA bridge: ServerWorks OSB4 South Bridge (rev 4f)
        Subsystem: ServerWorks OSB4 South Bridge
        Flags: bus master, medium devsel, latency 0

00:0f.1 IDE interface: ServerWorks OSB4 IDE Controller (prog-if 8a [Master SecP PriP])
        Flags: bus master, medium devsel, latency 64
        I/O ports at 0700 [size=16]

00:0f.2 USB Controller: ServerWorks OSB4/CSB5 OHCI USB Controller (rev 04) (prog-if 10 [OHCI])
        Subsystem: ServerWorks OSB4/CSB5 OHCI USB Controller
        Flags: bus master, medium devsel, latency 96, IRQ 19
        Memory at febfd000 (32-bit, non-prefetchable)

02:01.0 SCSI storage controller: Adaptec AIC-7899P U160/m (rev 01)
        Subsystem: Adaptec AIC-7899P U160/m
        Flags: bus master, 66Mhz, medium devsel, latency 100, IRQ 17
        BIST result: 00
        I/O ports at 4000 [disabled]
        Memory at efbff000 (64-bit, non-prefetchable) [size=4K]
        Capabilities: [dc] Power Management version 2

02:01.1 SCSI storage controller: Adaptec AIC-7899P U160/m (rev 01)
        Subsystem: Adaptec AIC-7899P U160/m
        Flags: bus master, 66Mhz, medium devsel, latency 100, IRQ 18
        BIST result: 00
        I/O ports at 4100 [disabled]
        Memory at efbfe000 (64-bit, non-prefetchable) [size=4K]
        Capabilities: [dc] Power Management version 2

02:05.0 RAID bus controller: IBM SCSI RAID Adapter [ServeRAID] (rev 10)
        Subsystem: IBM ServeRAID-4H
        Flags: bus master, medium devsel, latency 100, IRQ 24
        I/O ports at 4200
        Memory at efa00000 (32-bit, non-prefetchable) [size=1M]
        Capabilities: [40] Vital Product Data
        Capabilities: [48] Power Management version 2

02:06.0 Ethernet controller: Intel Corp. 82542 Gigabit Ethernet Controller (rev 03)
        Subsystem: IBM Netfinity Gigabit Ethernet SX Adapter
        Flags: bus master, medium devsel, latency 100, IRQ 25
        Memory at efbc0000 (32-bit, non-prefetchable)
        Capabilities: [dc] Power Management version 1

05:02.0 SCSI storage controller: QLogic Corp. QLA2200 64-bit Fibre Channel Adapter (rev 05)
        Subsystem: QLogic Corp. QLA2200
        Flags: bus master, 66Mhz, medium devsel, latency 96, IRQ 21
        I/O ports at 7000
        Memory at ec3ff000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [44] Power Management version 1

05:03.0 SCSI storage controller: QLogic Corp. QLA2200 64-bit Fibre Channel Adapter (rev 05)
        Subsystem: QLogic Corp. QLA2200
        Flags: bus master, 66Mhz, medium devsel, latency 96, IRQ 22
        I/O ports at 7100
        Memory at ec3fe000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [44] Power Management version 1

05:04.0 Ethernet controller: Netgear GA620 Gigabit Ethernet (rev 01)
        Subsystem: Netgear: Unknown device 0001
        Flags: bus master, 66Mhz, medium devsel, latency 96, IRQ 23
        Memory at ec3f8000 (32-bit, non-prefetchable)
