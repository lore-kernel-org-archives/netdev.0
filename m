From: Jos Vos <jos@xos.nl>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sat, 4 Dec 2004 18:20:13 +0100
Message-ID: <20041204182013.A8246@xos037.xos.nl>
References: <200412032325.iB3NPdG04693@xos037.xos.nl> <20041204005946.GA26654@electric-eye.fr.zoreil.com> <20041204021444.A5058@xos037.xos.nl> <20041204120328.GA1191@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041204120328.GA1191@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Dec 04, 2004 at 01:03:28PM +0100
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Dec 04, 2004 at 01:03:28PM +0100, Francois Romieu wrote:

> 1 - Imho people at RedHat/wherever need more details (chipset, mobo,
>     dmesg, lspci -vx, 2.4.21 savor ?).

Mainboard: Supermicro P4SCT+
Output of lspci -vx: attached
Red Hat kernel: 2.4.21-20.EL

> 2 - Testing recent 2.6.x will provide a different datapoint and a wider
>     review: a few people use e1000 for interested things here but they
>     do not necessarily have the resources to help with a specific vendor
>     released kernel. The vendor can use the datapoint though.

Yes, ok, I might install RHEL4 beta or Fedora Core 3 on it next week
and see how that works.

-- 
--    Jos Vos <jos@xos.nl>
--    X/OS Experts in Open Systems BV   |   Phone: +31 20 6938364
--    Amsterdam, The Netherlands        |     Fax: +31 20 6948204

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="lspci.txt"

00:00.0 Host bridge: Intel Corp. 82875P Memory Controller Hub (rev 02)
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: bus master, fast devsel, latency 0
	Memory at f0000000 (32-bit, prefetchable) [size=128M]
	Capabilities: [e4] #09 [3106]
00: 86 80 78 25 06 01 90 20 02 00 00 06 00 00 00 00
10: 08 00 00 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 e4 00 00 00 00 00 00 00 00 00 00 00

00:03.0 PCI bridge: Intel Corp. 82875P Processor to PCI to CSA Bridge (rev 02) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 32
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: fb200000-fb2fffff
00: 86 80 7b 25 07 01 a0 00 02 00 04 06 00 20 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 90 90 a0 22
20: 20 fb 20 fb f0 ff 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00

00:1c.0 PCI bridge: Intel Corp. 6300ESB 64-bit PCI-X Bridge (rev 02) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 32
	Bus: primary=00, secondary=02, subordinate=03, sec-latency=64
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: fb000000-fb1fffff
	Capabilities: [50] PCI-X non-bridge device.
00: 86 80 ae 25 07 01 30 80 02 00 04 06 10 20 01 00
10: 00 00 00 00 00 00 00 00 00 02 03 40 a0 a0 a0 22
20: 00 fb 10 fb f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 00 00 06 00

00:1d.0 USB Controller: Intel Corp. 6300ESB USB Universal Host Controller (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: bus master, medium devsel, latency 0, IRQ 16
	I/O ports at c400 [size=32]
00: 86 80 a9 25 05 00 80 02 02 00 03 0c 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 c4 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00

00:1d.1 USB Controller: Intel Corp. 6300ESB USB Universal Host Controller (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: bus master, medium devsel, latency 0, IRQ 19
	I/O ports at c000 [size=32]
00: 86 80 aa 25 05 00 80 02 02 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 c0 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 00 00 00 00 00 00 00 00 05 02 00 00

00:1d.4 System peripheral: Intel Corp. 6300ESB Watchdog Timer (rev 02)
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: medium devsel
	Memory at fb301000 (32-bit, non-prefetchable) [size=16]
00: 86 80 ab 25 02 00 80 02 02 00 80 08 00 00 00 00
10: 00 10 30 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:1d.5 PIC: Intel Corp. 6300ESB I/O Advanced Programmable Interrupt Controller (rev 02) (prog-if 20 [IO(X)-APIC])
	Subsystem: Intel Corp. 6300ESB I/O Advanced Programmable Interrupt Controller
	Flags: bus master, fast devsel, latency 0
	Capabilities: [50] PCI-X non-bridge device.
00: 86 80 ac 25 06 00 10 00 02 20 00 08 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 ac 25
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00

00:1d.7 USB Controller: Intel Corp. 6300ESB USB2 Enhanced Host Controller (rev 02) (prog-if 20 [EHCI])
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: bus master, medium devsel, latency 0, IRQ 23
	Memory at fb300000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
00: 86 80 ad 25 06 00 90 02 02 20 03 0c 00 00 00 00
10: 00 00 30 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 04 00 00

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB/ER Hub interface to PCI Bridge (rev 0a) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
	I/O behind bridge: 0000b000-0000bfff
	Memory behind bridge: f8000000-faffffff
00: 86 80 4e 24 07 01 80 00 0a 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 04 04 20 b0 b0 80 22
20: 00 f8 f0 fa f0 ff 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0e 00

00:1f.0 ISA bridge: Intel Corp. 6300ESB LPC Interface Controller (rev 02)
	Flags: bus master, medium devsel, latency 0
00: 86 80 a1 25 0f 00 80 02 02 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:1f.1 IDE interface: Intel Corp. 6300ESB PATA Storage Controller (rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: bus master, medium devsel, latency 0, IRQ 18
	I/O ports at <unassigned>
	I/O ports at <unassigned>
	I/O ports at <unassigned>
	I/O ports at <unassigned>
	I/O ports at f000 [size=16]
	Memory at 1ff00000 (32-bit, non-prefetchable) [size=1K]
00: 86 80 a2 25 07 00 88 02 02 8a 01 01 00 00 00 00
10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
20: 01 f0 00 00 00 00 f0 1f 00 00 00 00 d9 15 80 51
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00

00:1f.2 IDE interface: Intel Corp. 6300ESB SATA Storage Controller (rev 02) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 18
	I/O ports at c800 [size=8]
	I/O ports at cc00 [size=4]
	I/O ports at d000 [size=8]
	I/O ports at d400 [size=4]
	I/O ports at d800 [size=16]
00: 86 80 a3 25 05 00 a0 02 02 8f 01 01 00 00 00 00
10: 01 c8 00 00 01 cc 00 00 01 d0 00 00 01 d4 00 00
20: 01 d8 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 01 00 00

00:1f.3 SMBus: Intel Corp. 6300ESB SMBus Controller (rev 02)
	Subsystem: Super Micro Computer Inc: Unknown device 5180
	Flags: medium devsel, IRQ 17
	I/O ports at 0500 [size=32]
00: 86 80 a4 25 01 00 80 02 02 00 05 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 05 00 00 00 00 00 00 00 00 00 00 d9 15 80 51
30: 00 00 00 00 00 00 00 00 00 00 00 00 09 02 00 00

01:01.0 Ethernet controller: Intel Corp. 82547GI Gigabit Ethernet Controller
	Subsystem: Intel Corp. PRO/1000 CT Network Connection
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 18
	Memory at fb200000 (32-bit, non-prefetchable) [size=128K]
	I/O ports at 9000 [size=32]
	Capabilities: [dc] Power Management version 2
00: 86 80 75 10 07 00 38 02 00 00 00 02 08 00 00 00
10: 00 00 20 fb 00 00 00 00 01 90 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 75 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 ff 00

02:01.0 PCI bridge: IBM PCI-X to PCI-X Bridge (rev 02) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Bus: primary=02, secondary=03, subordinate=03, sec-latency=32
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: fb000000-fb0fffff
	Capabilities: [80] PCI-X non-bridge device.
	Capabilities: [90] Power Management version 2
00: 14 10 a7 01 07 01 30 02 02 00 04 06 08 20 01 00
10: 00 00 00 00 00 00 00 00 02 03 03 20 a1 a1 20 22
20: 00 fb 00 fb f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 ff 00 06 00

02:04.0 SCSI storage controller: Marvell Technology Group Ltd. MV88SX5041 4-port SATA I PCI-X Controller (rev 03)
	Subsystem: Marvell Technology Group Ltd. MV88SX5041 4-port SATA I PCI-X Controller
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 27
	Memory at fb100000 (64-bit, non-prefetchable) [size=512K]
	Capabilities: [40] Power Management version 2
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
	Capabilities: [60] PCI-X non-bridge device.
00: ab 11 41 50 07 00 b0 02 03 00 00 01 08 20 00 00
10: 04 00 10 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ab 11 41 50
30: 00 00 00 00 40 00 00 00 00 00 00 00 09 01 00 00

03:04.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Quad Port Server Adapter
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 267
	Memory at fb000000 (64-bit, non-prefetchable) [size=128K]
	I/O ports at a000 [size=64]
	Capabilities: [dc] Power Management version 2
	Capabilities: [e4] PCI-X non-bridge device.
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
00: 86 80 1d 10 07 00 30 02 01 00 00 02 08 20 80 00
10: 04 00 00 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 a0 00 00 00 00 00 00 00 00 00 00 86 80 00 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 ff 00

03:04.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Quad Port Server Adapter
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 267
	Memory at fb020000 (64-bit, non-prefetchable) [size=128K]
	I/O ports at a400 [size=64]
	Capabilities: [dc] Power Management version 2
	Capabilities: [e4] PCI-X non-bridge device.
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
00: 86 80 1d 10 07 00 30 02 01 00 00 02 08 20 80 00
10: 04 00 02 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 a4 00 00 00 00 00 00 00 00 00 00 86 80 00 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 09 02 ff 00

03:06.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Quad Port Server Adapter
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 26
	Memory at fb040000 (64-bit, non-prefetchable) [size=128K]
	I/O ports at a800 [size=64]
	Capabilities: [dc] Power Management version 2
	Capabilities: [e4] PCI-X non-bridge device.
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
00: 86 80 1d 10 07 00 30 02 01 00 00 02 08 20 80 00
10: 04 00 04 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 a8 00 00 00 00 00 00 00 00 00 00 86 80 00 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 ff 00

03:06.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Quad Port Server Adapter
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 27
	Memory at fb060000 (64-bit, non-prefetchable) [size=128K]
	I/O ports at ac00 [size=64]
	Capabilities: [dc] Power Management version 2
	Capabilities: [e4] PCI-X non-bridge device.
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
00: 86 80 1d 10 07 00 30 02 01 00 00 02 08 20 80 00
10: 04 00 06 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 ac 00 00 00 00 00 00 00 00 00 00 86 80 00 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 05 02 ff 00

04:09.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage XL
	Flags: bus master, stepping, medium devsel, latency 32, IRQ 17
	Memory at f8000000 (32-bit, non-prefetchable) [size=16M]
	I/O ports at b000 [size=256]
	Memory at fa020000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2
00: 02 10 52 47 87 00 90 02 27 00 00 03 08 20 00 00
10: 00 00 00 f8 01 b0 00 00 00 00 02 fa 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 08 80
30: 00 00 00 00 5c 00 00 00 00 00 00 00 09 01 08 00

04:0a.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit Ethernet Controller
	Subsystem: Intel Corp. PRO/1000 MT Network Connection
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 19
	Memory at fa000000 (32-bit, non-prefetchable) [size=128K]
	I/O ports at b400 [size=64]
	Capabilities: [dc] Power Management version 2
	Capabilities: [e4] PCI-X non-bridge device.
00: 86 80 76 10 07 00 30 02 00 00 00 02 08 20 00 00
10: 00 00 00 fa 00 00 00 00 01 b4 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 76 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 05 01 ff 00


--MGYHOYXEY6WxJCY8--
