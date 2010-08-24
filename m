From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: No link on e1000e with 2.6.35.3 and ThinkPad T60
Date: Tue, 24 Aug 2010 11:45:24 +0200
Message-ID: <20100824094524.GA17608@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:52191 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab0HXJpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 05:45:25 -0400
Content-Disposition: inline
In-Reply-To: <20100724092644.GA13353@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Jul 24, 2010 at 11:26:44AM +0200, Marc Haber wrote:
> Additionally, sometimes, probably after suspend/resume, the wired
> ethernet does not come up properly again, ip addr claims "NO CARRIER"
> even if the LEDs on the interface and on the switch claim that there
> was a link. No packets are received by the interface when it's at this
> stage.

As of 2.6.35.3, this issue has become worse. It now even happens
directly after freshly booting the system that I cannot get a link on
the wired ethernet.

What information do you need to find out what's going on there?

Please Cc: me on replies

Greetings
Marc

$ sudo ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: Unknown!
        Duplex: Unknown! (255)
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: Unknown
        Supports Wake-on: pumbag
        Wake-on: g
        Current message level: 0x00000001 (1)
        Link detected: no
$

[    0.000000]   #38 [0002810840 - 0002810850]         BOOTMEM
[    0.000000]   #39 [0002810880 - 00028108f3]         BOOTMEM
[    0.000000]   #40 [0002810900 - 0002810973]         BOOTMEM
[    0.000000]   #41 [0002c00000 - 0002c10000]         BOOTMEM
[    0.000000]   #42 [0002e00000 - 0002e10000]         BOOTMEM
[    0.000000]   #43 [0002812980 - 0002812984]         BOOTMEM
[    0.000000]   #44 [00028129c0 - 00028129c4]         BOOTMEM
[    0.000000]   #45 [0002812a00 - 0002812a08]         BOOTMEM
[    0.000000]   #46 [0002812a40 - 0002812a48]         BOOTMEM
[    0.000000]   #47 [0002812a80 - 0002812b28]         BOOTMEM
[    0.000000]   #48 [0002812b40 - 0002812ba8]         BOOTMEM
[    0.000000]   #49 [0002812bc0 - 0002816bc0]         BOOTMEM
[    0.000000]   #50 [0002816bc0 - 0002896bc0]         BOOTMEM
[    0.000000]   #51 [0002896bc0 - 00028d6bc0]         BOOTMEM
[    0.000000] Initializing HighMem for node 0 (000377fe:000bfed0)
[    0.000000] Memory: 3106840k/3144512k available (2664k kernel code, 37280k reserved, 1196k data, 468k init, 2235208k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff66000 - 0xfffff000   ( 612 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc04c6000 - 0xc053b000   ( 468 kB)
[    0.000000]       .data : 0xc039a0a3 - 0xc04c50dc   (1196 kB)
[    0.000000]       .text : 0xc0100000 - 0xc039a0a3   (2664 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000]  Verbose stalled-CPUs detection is disabled.
[    0.000000] NR_IRQS:384
[    0.000000] CPU 0 irqstacks, hard=c2c00000 soft=c2c01000
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2161.193 MHz processor.
[    0.004008] Calibrating delay loop (skipped), value calculated using timer frequency.. 4322.38 BogoMIPS (lpj=8644772)
[    0.004018] pid_max: default: 32768 minimum: 301
[    0.004107] Security Framework initialized
[    0.004150] Mount-cache hash table entries: 512
[    0.004406] CPU: Physical Processor ID: 0
[    0.004410] CPU: Processor Core ID: 0
[    0.004417] mce: CPU supports 6 MCE banks
[    0.004433] CPU0: Thermal monitoring enabled (TM2)
[    0.004440] using mwait in idle threads.
[    0.004451] Performance Events: PEBS fmt0-, Core2 events, Intel PMU driver.
[    0.004463] PEBS disabled due to CPU errata.
[    0.004474] ... version:                2
[    0.004478] ... bit width:              40
[    0.004482] ... generic registers:      2
[    0.004486] ... value mask:             000000ffffffffff
[    0.004491] ... max period:             000000007fffffff
[    0.004496] ... fixed-purpose events:   3
[    0.004500] ... event mask:             0000000700000003
[    0.006434] ACPI: Core revision 20100428
[    0.040017] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.040027] ftrace: allocating 13849 entries in 28 pages
[    0.044069] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.044482] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.086084] CPU0: Intel(R) Core(TM)2 CPU         T7400  @ 2.16GHz stepping 06
[    0.104036] CPU 1 irqstacks, hard=c2e00000 soft=c2e01000
[    0.104047] Booting Node   0, Processors  #1 Ok.
[    0.008000] Initializing CPU#1
[    0.196000] TSC synchronization [CPU#0 -> CPU#1]:
[    0.196000] Measured 668564 cycles TSC warp between CPUs, turning off TSC clock.
[    0.196000] Marking TSC unstable due to check_tsc_sync_source failed
[    0.196032] Brought up 2 CPUs
[    0.196037] Total of 2 processors activated (8644.99 BogoMIPS).
[    0.200073] devtmpfs: initialized
[    0.200266] regulator: core version 0.5
[    0.200266] NET: Registered protocol family 16
[    0.200266] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.200266] ACPI: bus type pci registered
[    0.200266] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf0000000-0xf3ffffff] (base 0xf0000000)
[    0.200266] PCI: MMCONFIG at [mem 0xf0000000-0xf3ffffff] reserved in E820
[    0.200266] PCI: Using MMCONFIG for extended config space
[    0.200266] PCI: Using configuration type 1 for base access
[    0.204080] bio: create slab <bio-0> at 0
[    0.212480] ACPI: EC: EC description table is found, configuring boot EC
[    0.237152] ACPI: SSDT bfef1d36 00282 (v01  PmRef  Cpu0Ist 00000100 INTL 20050513)
[    0.237613] ACPI: Dynamic OEM Table Load:
[    0.237613] ACPI: SSDT (null) 00282 (v01  PmRef  Cpu0Ist 00000100 INTL 20050513)
[    0.237613] ACPI: SSDT bfef203d 0065A (v01  PmRef  Cpu0Cst 00000100 INTL 20050513)
[    0.241054] ACPI: Dynamic OEM Table Load:
[    0.241062] ACPI: SSDT (null) 0065A (v01  PmRef  Cpu0Cst 00000100 INTL 20050513)
[    0.241866] ACPI: SSDT bfef1c6e 000C8 (v01  PmRef  Cpu1Ist 00000100 INTL 20050513)
[    0.243315] ACPI: Dynamic OEM Table Load:
[    0.243323] ACPI: SSDT (null) 000C8 (v01  PmRef  Cpu1Ist 00000100 INTL 20050513)
[    0.243609] ACPI: SSDT bfef1fb8 00085 (v01  PmRef  Cpu1Cst 00000100 INTL 20050513)
[    0.245058] ACPI: Dynamic OEM Table Load:
[    0.245065] ACPI: SSDT (null) 00085 (v01  PmRef  Cpu1Cst 00000100 INTL 20050513)
[    0.245281] ACPI: Interpreter enabled
[    0.245288] ACPI: (supports S0 S3 S4 S5)
[    0.245336] ACPI: Using IOAPIC for interrupt routing
[    0.264726] ACPI: EC: GPE = 0x1c, I/O: command/status = 0x66, data = 0x62
[    0.268107] ACPI: Power Resource [PUBS] (on)
[    0.272897] ACPI: ACPI Dock Station Driver: 3 docks/bays found
[    0.272907] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.273751] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.273817] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000d3fff] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [mem 0x000d4000-0x000d7fff] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [mem 0x000d8000-0x000dbfff] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [mem 0xc0000000-0xfebfffff] (ignored)
[    0.273817] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed40fff] (ignored)
[    0.273817] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:01.0: PME# disabled
[    0.273817] pci 0000:00:1b.0: reg 10: [mem 0xee400000-0xee403fff 64bit]
[    0.273817] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:1b.0: PME# disabled
[    0.273817] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:1c.0: PME# disabled
[    0.273817] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:1c.1: PME# disabled
[    0.273817] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:1c.2: PME# disabled
[    0.273817] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:1c.3: PME# disabled
[    0.273817] pci 0000:00:1d.0: reg 20: [io  0x1800-0x181f]
[    0.273817] pci 0000:00:1d.1: reg 20: [io  0x1820-0x183f]
[    0.273817] pci 0000:00:1d.2: reg 20: [io  0x1840-0x185f]
[    0.273817] pci 0000:00:1d.3: reg 20: [io  0x1860-0x187f]
[    0.273817] pci 0000:00:1d.7: reg 10: [mem 0xee404000-0xee4043ff]
[    0.273817] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.273817] pci 0000:00:1d.7: PME# disabled
[    0.273820] pci 0000:00:1f.0: quirk: [io  0x1000-0x107f] claimed by ICH6 ACPI/GPIO/TCO
[    0.273828] pci 0000:00:1f.0: quirk: [io  0x1180-0x11bf] claimed by ICH6 GPIO
[    0.273836] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 1600 (mask 007f)
[    0.273844] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 15e0 (mask 000f)
[    0.273852] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 1680 (mask 001f)
[    0.273924] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.273937] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.273950] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.273962] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.273974] pci 0000:00:1f.1: reg 20: [io  0x1880-0x188f]
[    0.274053] pci 0000:00:1f.2: reg 10: [io  0x18c8-0x18cf]
[    0.274066] pci 0000:00:1f.2: reg 14: [io  0x18ac-0x18af]
[    0.274078] pci 0000:00:1f.2: reg 18: [io  0x18c0-0x18c7]
[    0.274091] pci 0000:00:1f.2: reg 1c: [io  0x18a8-0x18ab]
[    0.274103] pci 0000:00:1f.2: reg 20: [io  0x18b0-0x18bf]
[    0.274116] pci 0000:00:1f.2: reg 24: [mem 0xee404400-0xee4047ff]
[    0.274168] pci 0000:00:1f.2: PME# supported from D3hot
[    0.276009] pci 0000:00:1f.2: PME# disabled
[    0.276093] pci 0000:00:1f.3: reg 20: [io  0x18e0-0x18ff]
[    0.276281] pci 0000:01:00.0: reg 10: [mem 0xd8000000-0xdfffffff pref]
[    0.276308] pci 0000:01:00.0: reg 14: [io  0x2000-0x20ff]
[    0.276335] pci 0000:01:00.0: reg 18: [mem 0xee100000-0xee10ffff]
[    0.276425] pci 0000:01:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.276539] pci 0000:01:00.0: supports D1 D2
[    0.276596] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.276603] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.276611] pci 0000:00:01.0:   bridge window [mem 0xee100000-0xee1fffff]
[    0.276621] pci 0000:00:01.0:   bridge window [mem 0xd8000000-0xdfffffff 64bit pref]
[    0.276770] pci 0000:02:00.0: reg 10: [mem 0xee000000-0xee01ffff]
[    0.276801] pci 0000:02:00.0: reg 18: [io  0x3000-0x301f]
[    0.276930] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.276941] pci 0000:02:00.0: PME# disabled
[    0.276979] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.276987] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
[    0.276996] pci 0000:00:1c.0:   bridge window [mem 0xee000000-0xee0fffff]
[    0.277010] pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    0.277240] pci 0000:03:00.0: reg 10: [mem 0xedf00000-0xedf00fff]
[    0.277507] pci 0000:03:00.0: PME# supported from D0 D3hot
[    0.277523] pci 0000:03:00.0: PME# disabled
[    0.277585] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.277593] pci 0000:00:1c.1:   bridge window [io  0x4000-0x5fff]
[    0.277602] pci 0000:00:1c.1:   bridge window [mem 0xec000000-0xedffffff]
[    0.277616] pci 0000:00:1c.1:   bridge window [mem 0xe4000000-0xe40fffff 64bit pref]
[    0.277699] pci 0000:00:1c.2: PCI bridge to [bus 04-0b]
[    0.277708] pci 0000:00:1c.2:   bridge window [io  0x6000-0x7fff]
[    0.277717] pci 0000:00:1c.2:   bridge window [mem 0xe8000000-0xe9ffffff]
[    0.277730] pci 0000:00:1c.2:   bridge window [mem 0xe4100000-0xe41fffff 64bit pref]
[    0.277814] pci 0000:00:1c.3: PCI bridge to [bus 0c-13]
[    0.277823] pci 0000:00:1c.3:   bridge window [io  0x8000-0x9fff]
[    0.277832] pci 0000:00:1c.3:   bridge window [mem 0xea000000-0xebffffff]
[    0.277845] pci 0000:00:1c.3:   bridge window [mem 0xe4200000-0xe42fffff 64bit pref]
[    0.277937] pci 0000:15:00.0: reg 10: [mem 0xe4300000-0xe4300fff]
[    0.277977] pci 0000:15:00.0: supports D1 D2
[    0.277982] pci 0000:15:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.277992] pci 0000:15:00.0: PME# disabled
[    0.278087] pci 0000:00:1e.0: PCI bridge to [bus 15-18] (subtractive decode)
[    0.278096] pci 0000:00:1e.0:   bridge window [io  0xa000-0xdfff]
[    0.278105] pci 0000:00:1e.0:   bridge window [mem 0xe4300000-0xe7ffffff]
[    0.278118] pci 0000:00:1e.0:   bridge window [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.278124] pci 0000:00:1e.0:   bridge window [io  0x0000-0xffff] (subtractive decode)
[    0.278130] pci 0000:00:1e.0:   bridge window [mem 0x00000000-0xffffffff] (subtractive decode)
[    0.278251] pci_bus 0000:00: on NUMA node 0
[    0.278260] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.278529] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
[    0.278670] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP0._PRT]
[    0.278810] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
[    0.278949] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP2._PRT]
[    0.279103] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP3._PRT]
[    0.279257] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
[    0.288571] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 *10 11)
[    0.292074] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *7 9 10 11)
[    0.292440] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 9 10 11)
[    0.292802] ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 7 9 10 11)
[    0.293164] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 *6 7 9 10 11)
[    0.293527] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11)
[    0.293888] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11)
[    0.294249] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 *11)
[    0.294410] HEST: Table is not found!
[    0.294410] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.294410] vgaarb: loaded
[    0.294410] SCSI subsystem initialized
[    0.294410] usbcore: registered new interface driver usbfs
[    0.294410] usbcore: registered new interface driver hub
[    0.294410] usbcore: registered new device driver usb
[    0.294410] PCI: Using ACPI for IRQ routing
[    0.294410] PCI: pci_cache_line_size set to 64 bytes
[    0.296085] reserve RAM buffer: 000000000009f000 - 000000000009ffff
[    0.296091] reserve RAM buffer: 00000000bfed0000 - 00000000bfffffff
[    0.296141] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.296141] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.296141] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.300078] Switching to clocksource hpet
[    0.304122] pnp: PnP ACPI init
[    0.304141] ACPI: bus type pnp registered
[    0.311754] pnp: PnP ACPI: found 11 devices
[    0.311759] ACPI: ACPI bus type pnp unregistered
[    0.311780] system 00:00: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.311788] system 00:00: [mem 0x000c0000-0x000c3fff] could not be reserved
[    0.311794] system 00:00: [mem 0x000c4000-0x000c7fff] could not be reserved
[    0.311801] system 00:00: [mem 0x000c8000-0x000cbfff] could not be reserved
[    0.311807] system 00:00: [mem 0x000cc000-0x000cffff] could not be reserved
[    0.311813] system 00:00: [mem 0x000dc000-0x000dffff] could not be reserved
[    0.311820] system 00:00: [mem 0x000e0000-0x000e3fff] could not be reserved
[    0.311826] system 00:00: [mem 0x000e4000-0x000e7fff] could not be reserved
[    0.311833] system 00:00: [mem 0x000e8000-0x000ebfff] could not be reserved
[    0.311839] system 00:00: [mem 0x000ec000-0x000effff] could not be reserved
[    0.311845] system 00:00: [mem 0x000f0000-0x000fffff] could not be reserved
[    0.311852] system 00:00: [mem 0x00100000-0xbfffffff] could not be reserved
[    0.311859] system 00:00: [mem 0xfec00000-0xfed3ffff] could not be reserved
[    0.311866] system 00:00: [mem 0xfed41000-0xffffffff] could not be reserved
[    0.311881] system 00:02: [io  0x164e-0x164f] has been reserved
[    0.311887] system 00:02: [io  0x1000-0x107f] has been reserved
[    0.311893] system 00:02: [io  0x1180-0x11bf] has been reserved
[    0.311900] system 00:02: [io  0x0800-0x080f] has been reserved
[    0.311906] system 00:02: [io  0x15e0-0x15ef] has been reserved
[    0.311912] system 00:02: [io  0x1600-0x165f] could not be reserved
[    0.311919] system 00:02: [mem 0xf0000000-0xf3ffffff] has been reserved
[    0.311925] system 00:02: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.311932] system 00:02: [mem 0xfed14000-0xfed17fff] has been reserved
[    0.311940] system 00:02: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.311947] system 00:02: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.347522] pci 0000:00:1c.0: BAR 9: assigned [mem 0xc0000000-0xc01fffff 64bit pref]
[    0.347531] pci 0000:01:00.0: BAR 6: assigned [mem 0xee120000-0xee13ffff pref]
[    0.347538] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.347544] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.347553] pci 0000:00:01.0:   bridge window [mem 0xee100000-0xee1fffff]
[    0.347560] pci 0000:00:01.0:   bridge window [mem 0xd8000000-0xdfffffff 64bit pref]
[    0.347570] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.347577] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
[    0.347588] pci 0000:00:1c.0:   bridge window [mem 0xee000000-0xee0fffff]
[    0.347597] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xc01fffff 64bit pref]
[    0.347610] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.347616] pci 0000:00:1c.1:   bridge window [io  0x4000-0x5fff]
[    0.347627] pci 0000:00:1c.1:   bridge window [mem 0xec000000-0xedffffff]
[    0.347636] pci 0000:00:1c.1:   bridge window [mem 0xe4000000-0xe40fffff 64bit pref]
[    0.347649] pci 0000:00:1c.2: PCI bridge to [bus 04-0b]
[    0.347656] pci 0000:00:1c.2:   bridge window [io  0x6000-0x7fff]
[    0.347666] pci 0000:00:1c.2:   bridge window [mem 0xe8000000-0xe9ffffff]
[    0.347675] pci 0000:00:1c.2:   bridge window [mem 0xe4100000-0xe41fffff 64bit pref]
[    0.347688] pci 0000:00:1c.3: PCI bridge to [bus 0c-13]
[    0.347695] pci 0000:00:1c.3:   bridge window [io  0x8000-0x9fff]
[    0.347705] pci 0000:00:1c.3:   bridge window [mem 0xea000000-0xebffffff]
[    0.347714] pci 0000:00:1c.3:   bridge window [mem 0xe4200000-0xe42fffff 64bit pref]
[    0.347729] pci 0000:15:00.0: BAR 9: assigned [mem 0xe0000000-0xe3ffffff pref]
[    0.347736] pci 0000:15:00.0: BAR 10: assigned [mem 0xc4000000-0xc7ffffff]
[    0.347742] pci 0000:15:00.0: BAR 7: assigned [io  0xa000-0xa0ff]
[    0.347748] pci 0000:15:00.0: BAR 8: assigned [io  0xa400-0xa4ff]
[    0.347753] pci 0000:15:00.0: CardBus bridge to [bus 16-17]
[    0.347758] pci 0000:15:00.0:   bridge window [io  0xa000-0xa0ff]
[    0.347768] pci 0000:15:00.0:   bridge window [io  0xa400-0xa4ff]
[    0.347778] pci 0000:15:00.0:   bridge window [mem 0xe0000000-0xe3ffffff pref]
[    0.347788] pci 0000:15:00.0:   bridge window [mem 0xc4000000-0xc7ffffff]
[    0.347798] pci 0000:00:1e.0: PCI bridge to [bus 15-18]
[    0.347804] pci 0000:00:1e.0:   bridge window [io  0xa000-0xdfff]
[    0.347815] pci 0000:00:1e.0:   bridge window [mem 0xe4300000-0xe7ffffff]
[    0.347824] pci 0000:00:1e.0:   bridge window [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.347852] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.347860] pci 0000:00:01.0: setting latency timer to 64
[    0.347879] pci 0000:00:1c.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    0.347888] pci 0000:00:1c.0: setting latency timer to 64
[    0.347906] pci 0000:00:1c.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    0.347915] pci 0000:00:1c.1: setting latency timer to 64
[    0.347934] pci 0000:00:1c.2: PCI INT C -> GSI 22 (level, low) -> IRQ 22
[    0.347942] pci 0000:00:1c.2: setting latency timer to 64
[    0.347961] pci 0000:00:1c.3: PCI INT D -> GSI 23 (level, low) -> IRQ 23
[    0.347969] pci 0000:00:1c.3: setting latency timer to 64
[    0.347979] pci 0000:00:1e.0: enabling device (0005 -> 0007)
[    0.347990] pci 0000:00:1e.0: setting latency timer to 64
[    0.348030] pci 0000:15:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.348042] pci_bus 0000:00: resource 0 [io  0x0000-0xffff]
[    0.348047] pci_bus 0000:00: resource 1 [mem 0x00000000-0xffffffff]
[    0.348053] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    0.348058] pci_bus 0000:01: resource 1 [mem 0xee100000-0xee1fffff]
[    0.348064] pci_bus 0000:01: resource 2 [mem 0xd8000000-0xdfffffff 64bit pref]
[    0.348070] pci_bus 0000:02: resource 0 [io  0x3000-0x3fff]
[    0.348075] pci_bus 0000:02: resource 1 [mem 0xee000000-0xee0fffff]
[    0.348080] pci_bus 0000:02: resource 2 [mem 0xc0000000-0xc01fffff 64bit pref]
[    0.348086] pci_bus 0000:03: resource 0 [io  0x4000-0x5fff]
[    0.348091] pci_bus 0000:03: resource 1 [mem 0xec000000-0xedffffff]
[    0.348096] pci_bus 0000:03: resource 2 [mem 0xe4000000-0xe40fffff 64bit pref]
[    0.348102] pci_bus 0000:04: resource 0 [io  0x6000-0x7fff]
[    0.348107] pci_bus 0000:04: resource 1 [mem 0xe8000000-0xe9ffffff]
[    0.348112] pci_bus 0000:04: resource 2 [mem 0xe4100000-0xe41fffff 64bit pref]
[    0.348118] pci_bus 0000:0c: resource 0 [io  0x8000-0x9fff]
[    0.348123] pci_bus 0000:0c: resource 1 [mem 0xea000000-0xebffffff]
[    0.348128] pci_bus 0000:0c: resource 2 [mem 0xe4200000-0xe42fffff 64bit pref]
[    0.348134] pci_bus 0000:15: resource 0 [io  0xa000-0xdfff]
[    0.348139] pci_bus 0000:15: resource 1 [mem 0xe4300000-0xe7ffffff]
[    0.348145] pci_bus 0000:15: resource 2 [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.348150] pci_bus 0000:15: resource 4 [io  0x0000-0xffff]
[    0.348155] pci_bus 0000:15: resource 5 [mem 0x00000000-0xffffffff]
[    0.348161] pci_bus 0000:16: resource 0 [io  0xa000-0xa0ff]
[    0.348166] pci_bus 0000:16: resource 1 [io  0xa400-0xa4ff]
[    0.348171] pci_bus 0000:16: resource 2 [mem 0xe0000000-0xe3ffffff pref]
[    0.348176] pci_bus 0000:16: resource 3 [mem 0xc4000000-0xc7ffffff]
[    0.348287] NET: Registered protocol family 2
[    0.348426] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.348925] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.349601] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.349908] TCP: Hash tables configured (established 131072 bind 65536)
[    0.349913] TCP reno registered
[    0.349919] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.349933] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.350100] NET: Registered protocol family 1
[    0.350304] pci 0000:01:00.0: Boot video device
[    0.350376] PCI: CLS mismatch (64 != 32), using 64 bytes
[    0.350463] Unpacking initramfs...
[    3.062966] Freeing initrd memory: 6812k freed
[    3.067836] Simple Boot Flag at 0x35 set to 0x1
[    3.069089] apm: BIOS not found.
[    3.069861] audit: initializing netlink socket (disabled)
[    3.069891] type=2000 audit(1282647962.068:1): initialized
[    3.070257] highmem bounce pool size: 64 pages
[    3.070840] msgmni has been set to 1715
[    3.071183] alg: No test for stdrng (krng)
[    3.071313] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
[    3.071319] io scheduler noop registered
[    3.071324] io scheduler deadline registered
[    3.071363] io scheduler cfq registered (default)
[    3.071594] pcieport 0000:00:01.0: setting latency timer to 64
[    3.071652] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[    3.071889] pcieport 0000:00:1c.0: setting latency timer to 64
[    3.071962] pcieport 0000:00:1c.0: irq 41 for MSI/MSI-X
[    3.072320] pcieport 0000:00:1c.1: setting latency timer to 64
[    3.072393] pcieport 0000:00:1c.1: irq 42 for MSI/MSI-X
[    3.072739] pcieport 0000:00:1c.2: setting latency timer to 64
[    3.072812] pcieport 0000:00:1c.2: irq 43 for MSI/MSI-X
[    3.073265] pcieport 0000:00:1c.3: setting latency timer to 64
[    3.073338] pcieport 0000:00:1c.3: irq 44 for MSI/MSI-X
[    3.074482] intel_idle: MWAIT substates: 0x22220
[    3.074487] intel_idle: does not run on family 6 model 15
[    3.075065] ACPI: AC Adapter [AC] (off-line)
[    3.075347] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input0
[    3.075581] ACPI: Lid Switch [LID]
[    3.075753] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input1
[    3.075759] ACPI: Sleep Button [SLPB]
[    3.075945] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    3.075950] ACPI: Power Button [PWRF]
[    3.076153] ACPI: acpi_idle registered with cpuidle
[    3.081107] Monitor-Mwait will be used to enter C-1 state
[    3.081162] Monitor-Mwait will be used to enter C-2 state
[    3.081215] Monitor-Mwait will be used to enter C-3 state
[    3.092443] thermal LNXTHERM:01: registered as thermal_zone0
[    3.092463] ACPI: Thermal Zone [THM0] (52 C)
[    3.094942] thermal LNXTHERM:02: registered as thermal_zone1
[    3.094959] ACPI: Thermal Zone [THM1] (49 C)
[    3.095152] ERST: Table is not found!
[    3.095156] GHES: HEST is not enabled!
[    3.095160] EINJ: Table is not found!
[    3.095179] isapnp: Scanning for PnP cards...
[    3.113146] ACPI: Battery Slot [BAT0] (battery present)
[    3.451028] isapnp: No Plug & Play device found
[    3.458735] nsc_gpio initializing
[    3.458739] ramoops: invalid size specification
[    3.458874] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    6.472033] floppy0: no floppy controllers found
[    6.472750] PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    6.481694] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.481707] serio: i8042 AUX port at 0x60,0x64 irq 12
[    6.481939] mice: PS/2 mouse device common for all mice
[    6.482663] cpuidle: using governor ladder
[    6.483850] cpuidle: using governor menu
[    6.484079] GACT probability on
[    6.484578] NET: Registered protocol family 17
[    6.484605] NET: Registered protocol family 15
[    6.484623] Using IPI No-Shortcut mode
[    6.486844] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input3
[    6.493504] registered taskstats version 1
[    6.494296] Freeing unused kernel memory: 468k freed
[    6.494644] Write protecting the kernel text: 2668k
[    6.494728] Write protecting the kernel read-only data: 940k
[    6.609172] udev: starting version 161
[    6.715258] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    6.756657] ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
[    6.759457] ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
[    6.759481] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    6.759518] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    6.759525] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    6.759638] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    6.759673] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    6.759693] ehci_hcd 0000:00:1d.7: debug port 1
[    6.763589] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    6.763623] ehci_hcd 0000:00:1d.7: irq 19, io mem 0xee404000
[    6.840043] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    6.840110] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    6.840116] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.840122] usb usb1: Product: EHCI Host Controller
[    6.840127] usb usb1: Manufacturer: Linux 2.6.35.3-zgws1 ehci_hcd
[    6.840131] usb usb1: SerialNumber: 0000:00:1d.7
[    6.840358] hub 1-0:1.0: USB hub found
[    6.840368] hub 1-0:1.0: 8 ports detected
[    6.849725] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k4
[    6.849731] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
[    6.849794] e1000e 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    6.849826] e1000e 0000:02:00.0: setting latency timer to 64
[    6.850080] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[    6.850579] e1000e 0000:02:00.0: Disabling ASPM L0s
[    6.877757] uhci_hcd: USB Universal Host Controller Interface driver
[    6.878071] Linux agpgart interface v0.103
[    6.878410] uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    6.878778] uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    6.878792] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    6.878806] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    6.878813] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    6.878965] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    6.879030] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001800
[    6.879096] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    6.879102] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.879108] usb usb2: Product: UHCI Host Controller
[    6.879112] usb usb2: Manufacturer: Linux 2.6.35.3-zgws1 uhci_hcd
[    6.879117] usb usb2: SerialNumber: 0000:00:1d.0
[    6.879454] hub 2-0:1.0: USB hub found
[    6.879465] hub 2-0:1.0: 2 ports detected
[    6.879601] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    6.879613] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    6.879620] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    6.879752] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    6.879806] uhci_hcd 0000:00:1d.1: irq 17, io base 0x00001820
[    6.879867] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    6.879873] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.879878] usb usb3: Product: UHCI Host Controller
[    6.879883] usb usb3: Manufacturer: Linux 2.6.35.3-zgws1 uhci_hcd
[    6.879888] usb usb3: SerialNumber: 0000:00:1d.1
[    6.880249] hub 3-0:1.0: USB hub found
[    6.880260] hub 3-0:1.0: 2 ports detected
[    6.880652] uhci_hcd 0000:00:1d.2: power state changed by ACPI to D0
[    6.880917] uhci_hcd 0000:00:1d.2: power state changed by ACPI to D0
[    6.880932] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    6.880944] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    6.880951] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    6.881023] libata version 3.00 loaded.
[    6.881116] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    6.881178] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001840
[    6.881268] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    6.881274] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.881280] usb usb4: Product: UHCI Host Controller
[    6.881284] usb usb4: Manufacturer: Linux 2.6.35.3-zgws1 uhci_hcd
[    6.881289] usb usb4: SerialNumber: 0000:00:1d.2
[    6.881651] hub 4-0:1.0: USB hub found
[    6.881661] hub 4-0:1.0: 2 ports detected
[    6.881806] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    6.881818] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    6.881831] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    6.881978] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    6.882028] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001860
[    6.882101] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    6.882107] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.882112] usb usb5: Product: UHCI Host Controller
[    6.882123] usb usb5: Manufacturer: Linux 2.6.35.3-zgws1 uhci_hcd
[    6.882127] usb usb5: SerialNumber: 0000:00:1d.3
[    6.882487] hub 5-0:1.0: USB hub found
[    6.882497] hub 5-0:1.0: 2 ports detected
[    6.892735] acpi device:05: registered as cooling_device2
[    6.893113] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:04/LNXVIDEO:01/input/input4
[    6.893127] ACPI: Video Device [VID1] (multi-head: yes  rom: no  post: no)
[    6.910914] ata_piix 0000:00:1f.1: version 2.13
[    6.910938] ata_piix 0000:00:1f.1: PCI INT C -> GSI 16 (level, low) -> IRQ 16
[    6.911005] ata_piix 0000:00:1f.1: setting latency timer to 64
[    6.917860] scsi0 : ata_piix
[    6.918154] scsi1 : ata_piix
[    6.919479] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1880 irq 14
[    6.919486] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1888 irq 15
[    6.920126] ata2: port disabled. ignoring.
[    6.969136] e1000e 0000:02:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:1a:6b:6a:07:60
[    6.969144] e1000e 0000:02:00.0: eth0: Intel(R) PRO/1000 Network Connection
[    6.969287] e1000e 0000:02:00.0: eth0: MAC: 2, PHY: 2, PBA No: 005301-003
[    7.084852] ata1.00: ATA-7: HTS541080G9SA00, MB4IC60R, max UDMA/100
[    7.084860] ata1.00: 156301488 sectors, multi 16: LBA48
[    7.101820] ata1.00: configured for UDMA/100
[    7.102087] scsi 0:0:0:0: Direct-Access     ATA      HTS541080G9SA00  MB4I PQ: 0 ANSI: 5
[    7.112470] ahci 0000:00:1f.2: version 3.0
[    7.112500] ahci 0000:00:1f.2: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    7.112615] ahci 0000:00:1f.2: irq 46 for MSI/MSI-X
[    7.112710] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 1.5 Gbps 0x1 impl SATA mode
[    7.112718] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part
[    7.112729] ahci 0000:00:1f.2: setting latency timer to 64
[    7.112908] scsi2 : ahci
[    7.113167] scsi3 : ahci
[    7.113370] scsi4 : ahci
[    7.113560] scsi5 : ahci
[    7.113797] ata3: SATA max UDMA/133 abar m1024@0xee404400 port 0xee404500 irq 46
[    7.113803] ata4: DUMMY
[    7.113806] ata5: DUMMY
[    7.113809] ata6: DUMMY
[    7.120460] sd 0:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 GB/74.5 GiB)
[    7.120577] sd 0:0:0:0: [sda] Write Protect is off
[    7.120584] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    7.120633] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    7.121056]  sda: sda1
[    7.150518] sd 0:0:0:0: [sda] Attached SCSI disk
[    7.432091] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    7.433439] ata3.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    7.433448] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    7.433456] ata3.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    7.434500] ata3.00: ATA-8: Hitachi HTS545050B9A300, PB4OC64G, max UDMA/133
[    7.434507] ata3.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    7.436094] ata3.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    7.436102] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    7.436110] ata3.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    7.437207] ata3.00: configured for UDMA/133
[    7.454719] ata3.00: configured for UDMA/133
[    7.454729] ata3: EH complete
[    7.454986] scsi 2:0:0:0: Direct-Access     ATA      Hitachi HTS54505 PB4O PQ: 0 ANSI: 5
[    7.455442] sd 2:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    7.455670] sd 2:0:0:0: [sdb] Write Protect is off
[    7.455677] sd 2:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    7.455768] sd 2:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    7.456239]  sdb: sdb1
[    7.480412] sd 2:0:0:0: [sdb] Attached SCSI disk
[    7.585062] usb 5-1: new full speed USB device using uhci_hcd and address 2
[    7.755103] usb 5-1: New USB device found, idVendor=0a5c, idProduct=2110
[    7.755111] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.755117] usb 5-1: Product: BCM2045B
[    7.755121] usb 5-1: Manufacturer: Broadcom Corp
[    7.790852] [drm] Initialized drm 1.1.0 20060810
[    7.855680] [drm] radeon kernel modesetting enabled.
[    7.855863] radeon 0000:01:00.0: power state changed by ACPI to D0
[    7.855946] radeon 0000:01:00.0: power state changed by ACPI to D0
[    7.855967] radeon 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    7.855989] radeon 0000:01:00.0: setting latency timer to 64
[    7.857936] [drm] initializing kernel modesetting (RV515 0x1002:0x7145).
[    7.860170] [drm] register mmio base: 0xEE100000
[    7.860175] [drm] register mmio size: 65536
[    7.860549] ATOM BIOS: M54CSP/M52CSP
[    7.860606] [drm] Generation 2 PCI interface, using max accessible memory
[    7.860619] radeon 0000:01:00.0: VRAM: 128M 0x00000000 - 0x07FFFFFF (128M used)
[    7.860626] radeon 0000:01:00.0: GTT: 512M 0x08000000 - 0x27FFFFFF
[    7.860922] radeon 0000:01:00.0: irq 47 for MSI/MSI-X
[    7.860948] [drm] radeon: using MSI.
[    7.861057] [drm] radeon: irq initialized.
[    7.863061] [drm] Detected VRAM RAM=128M, BAR=128M
[    7.863067] [drm] RAM width 128bits DDR
[    7.863211] [TTM] Zone  kernel: Available graphics memory: 439456 kiB.
[    7.863217] [TTM] Zone highmem: Available graphics memory: 1557060 kiB.
[    7.863222] [TTM] Initializing pool allocator.
[    7.863260] [drm] radeon: 128M of VRAM memory ready
[    7.863264] [drm] radeon: 512M of GTT memory ready.
[    7.863304] [drm] GART: num cpu pages 131072, num gpu pages 131072
[    7.865023] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
[    7.867491] [drm] PCIE GART of 512M enabled (table at 0x00040000).
[    7.867576] [drm] Loading R500 Microcode
[    7.873408] [drm] radeon: ring at 0x0000000008000000
[    7.873460] [drm] ring test succeeded in 3 usecs
[    7.873789] [drm] radeon: ib pool ready.
[    7.873944] [drm] ib test succeeded in 0 usecs
[    7.873992] [drm] Unknown TV standard; defaulting to NTSC
[    7.874293] [drm] Radeon Display Connectors
[    7.874297] [drm] Connector 0:
[    7.874301] [drm]   VGA
[    7.874306] [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
[    7.874311] [drm]   Encoders:
[    7.874314] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    7.874318] [drm] Connector 1:
[    7.874321] [drm]   LVDS
[    7.874327] [drm]   DDC: 0x7e60 0x7e60 0x7e64 0x7e64 0x7e68 0x7e68 0x7e6c 0x7e6c
[    7.874331] [drm]   Encoders:
[    7.874334] [drm]     LCD1: INTERNAL_LVTM1
[    7.874338] [drm] Connector 2:
[    7.874341] [drm]   DVI-I
[    7.874344] [drm]   HPD1
[    7.874349] [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
[    7.874354] [drm]   Encoders:
[    7.874357] [drm]     DFP1: INTERNAL_KLDSCP_TMDS1
[    7.946407] [drm] radeon: power management initialized
[    7.997113] usb 5-2: new full speed USB device using uhci_hcd and address 3
[    8.175138] usb 5-2: New USB device found, idVendor=0483, idProduct=2016
[    8.175145] usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    8.175151] usb 5-2: Product: Biometric Coprocessor
[    8.175155] usb 5-2: Manufacturer: STMicroelectronics
[    8.331765] [drm] fb mappable at 0xD80C0000
[    8.331771] [drm] vram apper at 0xD8000000
[    8.331775] [drm] size 7258112
[    8.331778] [drm] fb depth is 24
[    8.331782] [drm]    pitch is 6912
[    8.429339] Console: switching to colour frame buffer device 210x65
[    8.445192] fb0: radeondrmfb frame buffer device
[    8.445197] drm: registered panic notifier
[    8.445203] Slow work thread pool: Starting up
[    8.445400] Slow work thread pool: Ready
[    8.445411] [drm] Initialized radeon 2.5.0 20080528 for 0000:01:00.0 on minor 0
[   10.473092] device-mapper: ioctl: 4.17.0-ioctl (2010-03-05) initialised: dm-devel@redhat.com
[   11.565764] md: raid1 personality registered for level 1
[   11.637106] raid6: int32x1    342 MB/s
[   11.704077] raid6: int32x2    392 MB/s
[   11.772140] raid6: int32x4    313 MB/s
[   11.840083] raid6: int32x8    236 MB/s
[   11.908044] raid6: mmxx1     1310 MB/s
[   11.976036] raid6: mmxx2     1456 MB/s
[   12.044023] raid6: sse1x1     883 MB/s
[   12.112016] raid6: sse1x2    1069 MB/s
[   12.180037] raid6: sse2x1    1637 MB/s
[   12.248026] raid6: sse2x2    1933 MB/s
[   12.248031] raid6: using algorithm sse2x2 (1933 MB/s)
[   12.250448] xor: automatically using best checksumming function: pIII_sse
[   12.268012]    pIII_sse  :  3321.000 MB/sec
[   12.268018] xor: using function: pIII_sse (3321.000 MB/sec)
[   12.277791] md: raid6 personality registered for level 6
[   12.277797] md: raid5 personality registered for level 5
[   12.277802] md: raid4 personality registered for level 4
[   15.340383] PM: Starting manual resume from disk
[   15.366451] EXT3-fs: barriers not enabled
[   15.374907] EXT3-fs (dm-12): mounted filesystem with writeback data mode
[   15.375253] kjournald starting.  Commit interval 5 seconds
[   17.783591] udev: starting version 161
[   18.152924] intel_rng: FWH not detected
[   18.169437] i801_smbus 0000:00:1f.3: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[   18.171617] Non-volatile memory driver v1.3
[   18.246631] cfg80211: Calling CRDA to update world regulatory domain
[   18.320418] rtc_cmos 00:07: RTC can wake from S4
[   18.320600] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
[   18.320647] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[   18.351034] yenta_cardbus 0000:15:00.0: CardBus bridge found [17aa:2012]
[   18.477938] yenta_cardbus 0000:15:00.0: ISA IRQ mask 0x0cf8, PCI irq 16
[   18.477947] yenta_cardbus 0000:15:00.0: Socket status: 30000007
[   18.477959] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [io  0xa000-0xdfff]
[   18.477967] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa000-0xdfff: excluding 0xa000-0xa0ff 0xa400-0xa4ff
[   18.489211] Bluetooth: Core ver 2.15
[   18.489250] NET: Registered protocol family 31
[   18.489254] Bluetooth: HCI device and connection manager initialized
[   18.489260] Bluetooth: HCI socket layer initialized
[   18.519523]
[   18.519532] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xe4300000-0xe7ffffff]
[   18.519540] pcmcia_socket pcmcia_socket0: cs: memory probe 0xe4300000-0xe7ffffff: excluding 0xe4300000-0xe46cffff
[   18.519576] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xe0000000-0xe3ffffff 64bit pref]
[   18.519583] pcmcia_socket pcmcia_socket0: cs: memory probe 0xe0000000-0xe3ffffff: excluding 0xe0000000-0xe3ffffff
[   18.564431] Bluetooth: Generic Bluetooth USB driver ver 0.6
[   18.593117] usbcore: registered new interface driver btusb
[   18.876574] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[   18.876581] iwl3945: Copyright(c) 2003-2010 Intel Corporation
[   18.876714] iwl3945 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   18.876733] iwl3945 0000:03:00.0: setting latency timer to 64
[   18.891135] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x4ff: excluding 0x170-0x177 0x1f0-0x1f7 0x370-0x377 0x3c0-0x3df 0x3f0-0x3f7 0x4d0-0x4d7
[   18.895704] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x800-0x8ff: excluding 0x800-0x80f
[   18.898073] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcff: excluding 0xcf8-0xcff
[   18.900120] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff: excluding 0xc0000-0xcffff 0xdc000-0xfffff
[   18.900246] pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0ffffff: excluding 0xa0000000-0xa0ffffff
[   18.900368] pcmcia_socket pcmcia_socket0: cs: memory probe 0x60000000-0x60ffffff: excluding 0x60000000-0x60ffffff
[   18.900496] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaff: clean.
[   18.946627] iwl3945 0000:03:00.0: Tunable channels: 13 802.11bg, 23 802.11a channels
[   18.946635] iwl3945 0000:03:00.0: Detected Intel Wireless WiFi Link 3945ABG
[   18.946798] iwl3945 0000:03:00.0: irq 48 for MSI/MSI-X
[   19.017088] thinkpad_acpi: ThinkPad ACPI Extras v0.24
[   19.017094] thinkpad_acpi: http://ibm-acpi.sf.net/
[   19.017099] thinkpad_acpi: ThinkPad BIOS 7IET27WW (1.08 ), EC 79HT50WW-1.07
[   19.017104] thinkpad_acpi: Lenovo ThinkPad T60, model 87424SG
[   19.017109] thinkpad_acpi: WARNING: Outdated ThinkPad BIOS/EC firmware
[   19.017113] thinkpad_acpi: WARNING: This firmware may be missing critical bug fixes and/or important features
[   19.019448] thinkpad_acpi: detected a 8-level brightness capable ThinkPad
[   19.019828] thinkpad_acpi: radio switch found; radios are enabled
[   19.019857] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[   19.019863] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[   19.029712] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is unblocked
[   19.030340] Registered led device: tpacpi::thinklight
[   19.030844] Registered led device: tpacpi::power
[   19.031008] Registered led device: tpacpi::standby
[   19.031485] Registered led device: tpacpi::thinkvantage
[   19.033342] phy0: Selected rate control algorithm 'iwl-3945-rs'
[   19.034176] thinkpad_acpi: Standard ACPI backlight interface available, not loading native one.
[   19.036324] thinkpad_acpi: Console audio control enabled, mode: monitor (read only)
[   19.039736] Synaptics Touchpad, model: 1, fw: 6.2, id: 0x81a0b1, caps: 0xa04793/0x300000/0x0
[   19.039744] serio: Synaptics pass-through port at isa0060/serio1/input0
[   19.054150] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input5
[   19.086649] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio1/input/input6
[   19.159271] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[   19.159281] hda_intel: probe_mask set to 0x1 for device 17aa:2010
[   19.159385] HDA Intel 0000:00:1b.0: irq 49 for MSI/MSI-X
[   19.159443] HDA Intel 0000:00:1b.0: setting latency timer to 64
[   19.237188] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input7
[   20.129173] EXT3-fs (dm-12): using internal journal
[   24.800507] IBM TrackPoint firmware: 0x0e, buttons: 3/3
[   25.033225] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/serio2/input/input8
[   30.181486] coretemp coretemp.0: TjMax is assumed as 100 C!
[   30.181759] coretemp coretemp.1: TjMax is assumed as 100 C!
[   31.836619] Adding 3145208k swap on /dev/mapper/swap0.  Priority:-1 extents:1 across:3145208k
[  321.367151] EXT3-fs: barriers not enabled
[  321.376517] kjournald starting.  Commit interval 5 seconds
[  321.393057] EXT3-fs (dm-14): using internal journal
[  321.393069] EXT3-fs (dm-14): mounted filesystem with writeback data mode
[  321.419083] EXT3-fs: barriers not enabled
[  321.435435] kjournald starting.  Commit interval 5 seconds
[  321.460192] EXT3-fs (dm-17): using internal journal
[  321.460204] EXT3-fs (dm-17): mounted filesystem with writeback data mode
[  321.524249] EXT3-fs: barriers not enabled
[  321.543665] kjournald starting.  Commit interval 5 seconds
[  321.548233] EXT3-fs (dm-15): using internal journal
[  321.548244] EXT3-fs (dm-15): mounted filesystem with writeback data mode
[  321.599109] EXT3-fs: barriers not enabled
[  321.607378] kjournald starting.  Commit interval 5 seconds
[  321.616163] EXT3-fs (dm-16): using internal journal
[  321.616174] EXT3-fs (dm-16): mounted filesystem with writeback data mode
[  321.663580] EXT3-fs: barriers not enabled
[  321.681868] kjournald starting.  Commit interval 5 seconds
[  321.682267] EXT3-fs (dm-18): using internal journal
[  321.682278] EXT3-fs (dm-18): mounted filesystem with writeback data mode
[  321.735516] EXT3-fs: barriers not enabled
[  321.740345] kjournald starting.  Commit interval 5 seconds
[  321.744142] EXT3-fs (dm-20): using internal journal
[  321.744152] EXT3-fs (dm-20): mounted filesystem with writeback data mode
[  321.797878] EXT3-fs: barriers not enabled
[  321.815500] kjournald starting.  Commit interval 5 seconds
[  321.856253] EXT3-fs (dm-19): using internal journal
[  321.856266] EXT3-fs (dm-19): mounted filesystem with writeback data mode
[  327.426517] NET: Registered protocol family 10
[  327.427443] lo: Disabled Privacy Extensions
[  327.838732] Bridge firewalling registered
[  329.163680] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[  329.163687] All bugs added by David S. Miller <davem@redhat.com>
[  330.741567] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  330.797308] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  330.797980] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  331.444515] iwl3945 0000:03:00.0: loaded firmware version 15.32.2.9
[  331.530618] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  333.845719] vboxdrv: Trying to deactivate the NMI watchdog permanently...
[  333.845728] vboxdrv: Warning: 2.6.31+ kernel detected. Most likely the hardware performance
[  333.845731] vboxdrv: counter framework which can generate NMIs is active. You have to prevent
[  333.845734] vboxdrv: the usage of hardware performance counters by
[  333.845736] vboxdrv:   echo 2 > /proc/sys/kernel/perf_counter_paranoid
[  333.845744] vboxdrv: Found 2 processor cores.
[  333.845851] vboxdrv: fAsync=1 offMin=0xa2b67 offMax=0xa2b67
[  333.845951] vboxdrv: TSC mode is 'asynchronous', kernel timer mode is 'normal'.
[  333.845956] vboxdrv: Successfully loaded version 3.2.8_OSE (interface 0x00140001).
[  335.826167] ip_tables: (C) 2000-2006 Netfilter Core Team
[  335.921665] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[  335.921864] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
[  335.921869] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
[  335.921874] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
[  338.833025] br0: no IPv6 routers present
[  339.044693] Bluetooth: L2CAP ver 2.14
[  339.044698] Bluetooth: L2CAP socket layer initialized
[  339.730088] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[  339.730095] Bluetooth: BNEP filters: protocol multicast
[  339.931941] Bluetooth: SCO (Voice Link) ver 0.6
[  339.931947] Bluetooth: SCO socket layer initialized
[  340.499754] Bluetooth: RFCOMM TTY layer initialized
[  340.499765] Bluetooth: RFCOMM socket layer initialized
[  340.499769] Bluetooth: RFCOMM ver 1.11
[  341.004158] lp: driver loaded but no devices found
[  341.169361] ppdev: user-space parallel port driver
[  343.773076] device eth0 entered promiscuous mode
[  356.000029] usb 1-6: new high speed USB device using ehci_hcd and address 4
[  356.129554] usb 1-6: New USB device found, idVendor=04b3, idProduct=4485
[  356.129558] usb 1-6: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  356.129848] hub 1-6:1.0: USB hub found
[  356.129922] hub 1-6:1.0: 4 ports detected
[  356.401685] usb 1-6.1: new low speed USB device using ehci_hcd and address 5
[  356.476017] Monitor-Mwait will be used to enter C-3 state
[  356.517315] usb 1-6.1: New USB device found, idVendor=1bcf, idProduct=0007
[  356.517319] usb 1-6.1: New USB device strings: Mfr=0, Product=2, SerialNumber=0
[  356.517321] usb 1-6.1: Product: USB Optical Mouse
[  356.566607] usbcore: registered new interface driver hiddev
[  356.569998] input: USB Optical Mouse as /devices/pci0000:00/0000:00:1d.7/usb1/1-6/1-6.1/1-6.1:1.0/input/input9
[  356.570458] generic-usb 0003:1BCF:0007.0001: input,hiddev96,hidraw0: USB HID v1.10 Mouse [USB Optical Mouse] on usb-0000:00:1d.7-6.1/input0
[  356.570675] usbcore: registered new interface driver usbhid
[  356.570678] usbhid: USB HID core driver
[  357.408983] CPUFREQ: Per core ondemand sysfs interface is deprecated - ignore_nice_load
[  359.597108] usb 1-6.3: new high speed USB device using ehci_hcd and address 6
[  359.693085] usb 1-6.3: New USB device found, idVendor=13fd, idProduct=1340
[  359.693089] usb 1-6.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[  359.693092] usb 1-6.3: Product: External
[  359.693094] usb 1-6.3: Manufacturer: Generic
[  359.693096] usb 1-6.3: SerialNumber: 9QG1Z559
[  359.784921] Initializing USB Mass Storage driver...
[  359.801850] scsi6 : usb-storage 1-6.3:1.0
[  359.802034] usbcore: registered new interface driver usb-storage
[  359.802037] USB Mass Storage support registered.
[  360.812627] scsi 6:0:0:0: Direct-Access     Generic  External         1.04 PQ: 0 ANSI: 4
[  360.814600] sd 6:0:0:0: [sdc] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[  360.815345] sd 6:0:0:0: [sdc] Write Protect is off
[  360.815349] sd 6:0:0:0: [sdc] Mode Sense: 21 00 00 00
[  360.815352] sd 6:0:0:0: [sdc] Assuming drive cache: write through
[  360.816727] sd 6:0:0:0: [sdc] Assuming drive cache: write through
[  360.816734]  sdc: sdc1 sdc2 sdc3
[  360.837748] sd 6:0:0:0: [sdc] Assuming drive cache: write through
[  360.837752] sd 6:0:0:0: [sdc] Attached SCSI disk
[  364.085084] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[  364.086101] input: Logitech Elite Keyboard as /devices/pci0000:00/0000:00:1d.3/usb5/5-1/5-1:1.0/bluetooth/hci0/hci0:11/input10
[  364.086229] generic-bluetooth 0005:046D:B301.0002: input,hidraw1: BLUETOOTH HID v23.02 Keyboard [Logitech Elite Keyboard] on 00:19:7E:F6:0F:2D
[  371.961530] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  372.538486] device eth0 left promiscuous mode
[  372.622183] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  372.677242] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  372.677773] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  372.879954] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  377.850201] wlan0: authenticate with 00:24:fe:01:97:12 (try 1)
[  377.853703] wlan0: authenticated
[  377.854219] wlan0: associate with 00:24:fe:01:97:12 (try 1)
[  377.874032] wlan0: RX AssocResp from 00:24:fe:01:97:12 (capab=0x431 status=0 aid=1)
[  377.874035] wlan0: associated
[  377.876283] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[  384.269049] CE: hpet increased min_delta_ns to 7500 nsec
[  387.936024] wlan0: no IPv6 routers present
[  412.458666] input: Logitech MX900 Mouse as /devices/pci0000:00/0000:00:1d.3/usb5/5-1/5-1:1.0/bluetooth/hci0/hci0:12/input11
[  412.458793] generic-bluetooth 0005:046D:B001.0003: input,hidraw2: BLUETOOTH HID v22.00 Mouse [Logitech MX900 Mouse] on 00:19:7E:F6:0F:2D
[  415.386604] tun: Universal TUN/TAP device driver, 1.6
[  415.386607] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[  415.387661] tun0: Disabled Privacy Extensions
[  448.565074] wlan0: deauthenticating from 00:24:fe:01:97:12 by local choice (reason=3)
[  448.611692] cfg80211: Calling CRDA to update world regulatory domain
[  448.704992] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  448.952477] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  449.008212] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  449.008883] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  449.244497] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  449.300213] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  449.300899] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  512.719141] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  512.893054] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  513.145602] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  513.201263] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  513.201930] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  516.041691] CE: hpet increased min_delta_ns to 11250 nsec
[  517.785033] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  518.032489] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  518.089220] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  518.089925] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  518.276821] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  525.979923] wlan0: authenticate with 00:24:fe:01:97:12 (try 1)
[  525.983876] wlan0: authenticated
[  525.983914] wlan0: associate with 00:24:fe:01:97:12 (try 1)
[  525.986924] wlan0: RX AssocResp from 00:24:fe:01:97:12 (capab=0x431 status=0 aid=1)
[  525.986930] wlan0: associated
[  525.988635] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[  536.388020] wlan0: no IPv6 routers present
[  678.841587] CE: hpet increased min_delta_ns to 16875 nsec
[  712.538091] usb 1-6: USB disconnect, address 4
[  712.538098] usb 1-6.1: USB disconnect, address 5
[  712.560502] usb 1-6.3: USB disconnect, address 6
[  724.069150] wlan0: deauthenticating from 00:24:fe:01:97:12 by local choice (reason=3)
[  724.224797] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  724.224816] cfg80211: Calling CRDA to update world regulatory domain
[  724.456592] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  724.513342] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  724.514012] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  724.737607] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  724.793247] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  724.793783] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  788.790038] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  788.953160] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  789.204655] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  789.261316] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  789.261998] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  907.217156] usb 1-6: new high speed USB device using ehci_hcd and address 7
[  907.348507] usb 1-6: New USB device found, idVendor=04b3, idProduct=4485
[  907.348515] usb 1-6: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  907.349162] hub 1-6:1.0: USB hub found
[  907.349342] hub 1-6:1.0: 4 ports detected
[  907.620215] usb 1-6.1: new low speed USB device using ehci_hcd and address 8
[  907.716957] usb 1-6.1: New USB device found, idVendor=1bcf, idProduct=0007
[  907.716961] usb 1-6.1: New USB device strings: Mfr=0, Product=2, SerialNumber=0
[  907.716964] usb 1-6.1: Product: USB Optical Mouse
[  907.721160] input: USB Optical Mouse as /devices/pci0000:00/0000:00:1d.7/usb1/1-6/1-6.1/1-6.1:1.0/input/input12
[  907.721328] generic-usb 0003:1BCF:0007.0004: input,hiddev96,hidraw0: USB HID v1.10 Mouse [USB Optical Mouse] on usb-0000:00:1d.7-6.1/input0
[  910.964131] usb 1-6.3: new high speed USB device using ehci_hcd and address 9
[  911.057374] usb 1-6.3: New USB device found, idVendor=13fd, idProduct=1340
[  911.057378] usb 1-6.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[  911.057381] usb 1-6.3: Product: External
[  911.057383] usb 1-6.3: Manufacturer: Generic
[  911.057385] usb 1-6.3: SerialNumber: 9QG1Z559
[  911.059506] scsi7 : usb-storage 1-6.3:1.0
[  912.058328] scsi 7:0:0:0: Direct-Access     Generic  External         1.04 PQ: 0 ANSI: 4
[  912.061133] sd 7:0:0:0: [sdc] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[  912.062537] sd 7:0:0:0: [sdc] Write Protect is off
[  912.062540] sd 7:0:0:0: [sdc] Mode Sense: 21 00 00 00
[  912.062543] sd 7:0:0:0: [sdc] Assuming drive cache: write through
[  912.066724] sd 7:0:0:0: [sdc] Assuming drive cache: write through
[  912.066732]  sdc: sdc1 sdc2 sdc3
[  912.082246] sd 7:0:0:0: [sdc] Assuming drive cache: write through
[  912.082251] sd 7:0:0:0: [sdc] Attached SCSI disk
[  921.728801] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  921.972508] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  922.028259] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  922.028914] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  922.253501] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  922.308255] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  922.308924] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  985.765192] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  986.012471] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  986.065649] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  986.066209] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  994.748266] e1000e 0000:02:00.0: PCI INT A disabled
[  998.921330] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k4
[  998.921333] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
[  998.921442] e1000e 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  998.921469] e1000e 0000:02:00.0: setting latency timer to 64
[  998.921746] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[  998.921923] e1000e 0000:02:00.0: Disabling ASPM L0s
[  999.036845] e1000e 0000:02:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:1a:6b:6a:07:60
[  999.036849] e1000e 0000:02:00.0: eth0: Intel(R) PRO/1000 Network Connection
[  999.036988] e1000e 0000:02:00.0: eth0: MAC: 2, PHY: 2, PBA No: 005301-003
[ 1002.765033] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 1002.897510] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[ 1002.952256] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[ 1002.952921] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 1003.144462] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[ 1003.200238] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[ 1003.201139] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 1003.433530] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[ 1003.488266] e1000e 0000:02:00.0: irq 45 for MSI/MSI-X
[ 1003.488933] ADDRCONF(NETDEV_UP): eth0: link is not ready


-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
