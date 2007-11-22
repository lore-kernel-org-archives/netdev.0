From: Simon Arlott <simon@fire.lp0.eu>
Subject: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Thu, 22 Nov 2007 19:47:35 +0000
Message-ID: <4745DCD7.8070805@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:59851 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbXKVTrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 14:47:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARN during log message being output to ttyS0 and netconsole:

[2059664.615816] __iptables__: init4 IN=3Dppp0 OUT=3Dppp0 WARNING: at k=
ernel/softirq.c:139 local_bh_enable()
[2059664.620535]  [<80120364>] local_bh_enable+0x3c/0x97
[2059664.620553]  [<802e3356>] __nf_ct_ext_destroy+0x35/0x5b
[2059664.620569]  [<802dfbeb>] destroy_conntrack+0x5e/0xf6
[2059664.620577]  [<802db821>] nf_conntrack_destroy+0x1f/0x3f
[2059664.620585]  [<802c0c71>] __kfree_skb+0xb8/0xf6
[2059664.620597]  [<802d00f0>] zap_completion_queue+0x3e/0x64
[2059664.620606]  [<802d0583>] find_skb+0x14/0x6b
[2059664.620612]  [<801167cc>] inc_nr_running+0x12/0x25
[2059664.620622]  [<802d0fd8>] netpoll_send_udp+0x2d/0x251
[2059664.620630]  [<80226135>] uart_console_write+0x2a/0x33
[2059664.620645]  [<80241319>] write_msg+0x32/0x41
[2059664.620657]  [<8011c205>] __call_console_drivers+0x61/0x6d
[2059664.620669]  [<8011c3fc>] release_console_sem+0x164/0x1bf
[2059664.620679]  [<8011c81f>] vprintk+0x27a/0x2ff
[2059664.620692]  [<8013881e>] handle_IRQ_event+0x1a/0x3f
[2059664.620702]  [<801203a5>] local_bh_enable+0x7d/0x97
[2059664.620709]  [<8031ae6a>] fn_hash_lookup+0xb0/0xcd
[2059664.620723]  [<8011c8bf>] printk+0x1b/0x1f
[2059664.620731]  [<8032b372>] ipt_log_packet+0x71/0x15e
[2059664.620747]  [<8032b4a0>] ipt_log_target+0x41/0x4a
[2059664.620757]  [<802ea446>] ipt_limit_match+0x58/0x76
[2059664.620766]  [<8032b45f>] ipt_log_target+0x0/0x4a
[2059664.620774]  [<803288c5>] ipt_do_table+0x3e2/0x479
[2059664.620785]  [<80331228>] xfrm_policy_put_afinfo+0xa/0x1e
[2059664.620800]  [<80332219>] xfrm_lookup+0x15/0x69
[2059664.620809]  [<802db7d0>] nf_iterate+0x38/0x6a
[2059664.620822]  [<802dbb60>] nf_hook_slow+0x57/0xe0
[2059664.620830]  [<802f1e7c>] ip_forward_finish+0x0/0x22
[2059664.620841]  [<802f20d1>] ip_forward+0x233/0x2ae
[2059664.620849]  [<802f1e7c>] ip_forward_finish+0x0/0x22
[2059664.620859]  [<802f0e7a>] ip_rcv+0x46f/0x49c
[2059664.620866]  [<802f04a8>] ip_rcv_finish+0x0/0x2ab
[2059664.620876]  [<802f0a0b>] ip_rcv+0x0/0x49c
[2059664.620884]  [<802c544a>] netif_receive_skb+0x326/0x3ae
[2059664.620894]  [<802c6efe>] process_backlog+0x6d/0xd2
[2059664.620903]  [<802c766e>] net_rx_action+0x86/0x193
[2059664.620911]  [<80120001>] __do_softirq+0x40/0x85
[2059664.620919]  [<8012006d>] do_softirq+0x27/0x2b
[2059664.620925]  [<8012023d>] irq_exit+0x2d/0x37
[2059664.620931]  [<801062d9>] do_IRQ+0x7a/0x8d
[2059664.620943]  [<8010479b>] common_interrupt+0x23/0x28
[2059664.620954]  [<80209f85>] acpi_processor_idle+0x235/0x3a0
[2059664.620967]  [<80102344>] cpu_idle+0x43/0x6c
[2059664.620973]  [<804aa99e>] start_kernel+0x210/0x215
[2059664.620989]  [<804aa317>] unknown_bootoption+0x0/0x195
[2059664.620998]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[2059664.852188] SRC=3D66.249.93.147 DST=3D* LEN=3D40 TOS=3D0x00 PREC=3D=
0x00 TTL=3D53 ID=3D23868 DF PROTO=3DTCP SPT=3D80 DPT=3D55219 WINDOW=3D0=
 RES=3D0x00 RST URGP=3D0


[    0.000000] Linux version 2.6.23-git (byte@proxima) (gcc version 4.1=
=2E2 20070214 ( (gdc 0.23, using dmd 1.007)) (Gentoo 4.1.2)) #41 PREEMP=
T Sun Oct 21 20:42:28 BST 2007
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fee0000 (usable)
[    0.000000]  BIOS-e820: 000000003fee0000 - 000000003fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000003fee3000 - 000000003fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000003fef0000 - 000000003ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserve=
d)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 1022MB LOWMEM available.
[    0.000000] found SMP MP-table at 000f4d50
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Entering add_active_range(0, 0, 261856) 0 entries of 256=
 used
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->   261856
[    0.000000]   HighMem    261856 ->   261856
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->   261856
[    0.000000] On node 0 totalpages: 261856
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 4064 pages, LIFO batch:0
[    0.000000]   Normal zone: 2013 pages used for memmap
[    0.000000]   Normal zone: 255747 pages, LIFO batch:31
[    0.000000]   HighMem zone: 0 pages used for memmap
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] DMI 2.3 present.
[    0.000000] ACPI: RSDP 000F6E10, 0014 (r0 CN700 )
[    0.000000] ACPI: RSDT 3FEE3040, 002C (r1 CN700  AWRDACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 3FEE30C0, 0074 (r1 CN700  AWRDACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 3FEE3180, 4FC3 (r1 CN700  AWRDACPI     1000 M=
SFT  100000E)
[    0.000000] ACPI: FACS 3FEE0000, 0040
[    0.000000] ACPI: APIC 3FEE81C0, 005A (r1 CN700  AWRDACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] Processor #0 6:10 APIC version 20
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: Skipping IOAPIC probe due to 'noapic' option.
[    0.000000] Using ACPI for processor (LAPIC) configuration informati=
on
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000] OEM ID: OEM00000 Product ID: PROD00000000 APIC at: 0xFEE=
00000
[    0.000000] I/O APIC #2 Version 17 at 0xFEC00000.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Processors: 1
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 3ff0=
0000:bed00000)
[    0.000000] Built 1 zonelists in Zone order.  Total pages: 259811
[    0.000000] Kernel command line: root=3D/dev/hda1 ro panic=3D10 netc=
onsole=3D9@192.168.7.4/eth0,1649@192.168.7.255/ noapic console=3Dtty0 c=
onsole=3DttyS0,115200
[    0.000000] mapped APIC to ffffb000 (fee00000)
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Detected 1500.153 MHz processor.
[   14.647474] Console: colour dummy device 80x25
[   14.647481] console [tty0] enabled
[   14.647699] console [ttyS0] enabled
[   14.941991] Dentry cache hash table entries: 131072 (order: 7, 52428=
8 bytes)
[   14.950229] Inode-cache hash table entries: 65536 (order: 6, 262144 =
bytes)
[   15.005288] Memory: 1033552k/1047424k available (2593k kernel code, =
13388k reserved, 1145k data, 184k init, 0k highmem)
[   15.016075] virtual kernel memory layout:
[   15.016077]     fixmap  : 0xfffa8000 - 0xfffff000   ( 348 kB)
[   15.016081]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[   15.016084]     vmalloc : 0xc0800000 - 0xffbfe000   (1011 MB)
[   15.016087]     lowmem  : 0x80000000 - 0xbfee0000   (1022 MB)
[   15.016090]       .init : 0x804aa000 - 0x804d8000   ( 184 kB)
[   15.016093]       .data : 0x80388720 - 0x804a6dbc   (1145 kB)
[   15.016096]       .text : 0x80100000 - 0x80388720   (2593 kB)
[   15.060188] Checking if this processor honours the WP bit even in su=
pervisor mode... Ok.
[   15.148426] Calibrating delay using timer specific routine.. 3002.32=
 BogoMIPS (lpj=3D6004643)
[   15.156857] Security Framework v1.0.0 initialized
[   15.161589] Mount-cache hash table entries: 512
[   15.166285] CPU: After generic identify, caps: a7c9bbff 00100000 000=
00000 00000000 00000181 00000000 00000000 00000000
[   15.166303] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 by=
tes/line)
[   15.173433] CPU: L2 Cache: 128K (64 bytes/line)
[   15.177960] CPU: After all inits, caps: 27c9bbff 00100000 00000000 0=
0000000 00000181 00003fcc 00000000 00000000
[   15.177980] Compat vDSO mapped to ffffe000.
[   15.182174] CPU: Centaur VIA Esther processor 1500MHz stepping 09
[   15.188300] Checking 'hlt' instruction... OK.
[   15.205044] ACPI: Core revision 20070126
[   15.214086] Parsing all Control Methods:
[   15.218032] Table [DSDT](id 0001) - 676 Objects with 57 Devices 178 =
Methods 38 Regions
[   15.226134]  tbxface-0598 [00] tb_load_namespace     : ACPI Tables s=
uccessfully acquired
[   15.234256] ACPI: setting ELCR to 0200 (from 0ea0)
[   15.266502] evxfevnt-0091 [00] enable                : Transition to=
 ACPI mode successful
[   15.380608] NET: Registered protocol family 16
[   15.385280] ACPI: bus type pci registered
[   15.397856] PCI: PCI BIOS revision 2.10 entry at 0xfa9b0, last bus=3D=
1
[   15.404208] PCI: Using configuration type 1
[   15.408389] Setting up standard PCI resources
[   15.415770] evgpeblk-0956 [00] ev_create_gpe_block   : GPE 00 to 0F =
[_GPE] 2 regs on int 0x9
[   15.424744] evgpeblk-1052 [00] ev_initialize_gpe_bloc: Found 5 Wake,=
 Enabled 0 Runtime GPEs in this block
[   15.434348] ACPI: EC: Look up EC in DSDT
[   15.440740] Completing Region/Field/Buffer/Package initialization:..=
=2E....................................................................=
=2E.
[   15.457628] Initialized 23/38 Regions 18/18 Fields 18/18 Buffers 14/=
24 Packages (685 nodes)
[   15.466162] Initializing Device/Processor/Thermal objects by executi=
ng _INI methods:..
[   15.475939] Executed 2 _INI methods requiring 1 _STA executions (exa=
mined 61 objects)
[   15.484013] ACPI: Interpreter enabled
[   15.487679] ACPI: (supports S0 S1 S5)
[   15.491404] ACPI: Using PIC for interrupt routing
[   15.508082] ACPI: PCI Root Bridge [PCI0] (0000:00)
[   15.514008] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[   15.603552] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 *7 10 11 12)
[   15.610379] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 6 7 10 11 12) =
*5
[   15.617383] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 *10 11 12)
[   15.624191] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 *11 12)
[   15.630938] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[   15.638840] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[   15.646733] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[   15.654633] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[   15.662610] ACPI: PCI Interrupt Link [ALKA] (IRQs *20), disabled.
[   15.669089] ACPI: PCI Interrupt Link [ALKB] (IRQs *21)
[   15.674591] ACPI: PCI Interrupt Link [ALKC] (IRQs *22)
[   15.680160] ACPI: PCI Interrupt Link [ALKD] (IRQs *23), disabled.
[   15.686489] Linux Plug and Play Support v0.97 (c) Adam Belay
[   15.692194] pnp: PnP ACPI init
[   15.695264] ACPI: bus type pnp registered
[   15.705810] pnp: PnP ACPI: found 10 devices
[   15.710014] ACPI: ACPI bus type pnp unregistered
[   15.714958] SCSI subsystem initialized
[   15.718858] usbcore: registered new interface driver usbfs
[   15.724424] usbcore: registered new interface driver hub
[   15.729789] usbcore: registered new device driver usb
[   15.735063] PCI: Using ACPI for IRQ routing
[   15.739249] PCI: If a device doesn't work, try "pci=3Drouteirq".  If=
 it helps, post a report
[   15.771871] NET: Registered protocol family 8
[   15.776230] NET: Registered protocol family 20
[   15.783850] Time: tsc clocksource has been installed.
[   15.795894] pnp: 00:00: iomem range 0xf0000-0xf3fff could not be res=
erved
[   15.802679] pnp: 00:00: iomem range 0xf4000-0xf7fff could not be res=
erved
[   15.809462] pnp: 00:00: iomem range 0xf8000-0xfbfff could not be res=
erved
[   15.816246] pnp: 00:00: iomem range 0xfc000-0xfffff could not be res=
erved
[   15.823037] pnp: 00:02: ioport range 0x400-0x47f has been reserved
[   15.829216] pnp: 00:02: ioport range 0x500-0x50f has been reserved
[   15.865864] PCI: Bridge: 0000:00:01.0
[   15.869533]   IO window: e000-efff
[   15.872941]   MEM window: fde00000-fdefffff
[   15.877126]   PREFETCH window: fdd00000-fddfffff
[   15.881764] PCI: Setting latency timer of device 0000:00:01.0 to 64
[   15.881831] NET: Registered protocol family 2
[   15.923781] IP route cache hash table entries: 32768 (order: 5, 1310=
72 bytes)
[   15.931174] TCP established hash table entries: 131072 (order: 8, 10=
48576 bytes)
[   15.940310] TCP bind hash table entries: 65536 (order: 6, 262144 byt=
es)
[   15.947441] TCP: Hash tables configured (established 131072 bind 655=
36)
[   15.954072] TCP reno registered
[   15.968368] Total HugeTLB memory allocated, 0
[   15.972853] VFS: Disk quotas dquot_6.5.1
[   15.976796] Dquot-cache hash table entries: 1024 (order 0, 4096 byte=
s)
[   15.983544] io scheduler noop registered
[   15.987468] io scheduler anticipatory registered
[   15.992082] io scheduler deadline registered
[   15.996376] io scheduler cfq registered (default)
[   16.001095] PCI: VIA PCI bridge detected. Disabling DAC.
[   16.163498] 0000:00:10.4 EHCI: BIOS handoff failed (BIOS bug ?) 0101=
0001
[   16.170202] PCI: Bypassing VIA 8237 APIC De-Assert Message
[   16.176025] input: Power Button (FF) as /devices/virtual/input/input=
0
[   16.182469] ACPI: Power Button (FF) [PWRF]
[   16.186687] input: Power Button (CM) as /devices/virtual/input/input=
1
[   16.193123] ACPI: Power Button (CM) [PWRB]
[   16.197298] ACPI: Fan [FAN] (on)
[   16.200826] ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
[   16.206458] ACPI: Processor [CPU0] (supports 2 throttling states)
[   16.213644] ACPI: Thermal Zone [THRM] (40 C)
[   16.283093] Real Time Clock Driver v1.12ac
[   16.287378] Non-volatile memory driver v1.2
[   16.291593] VIA RNG detected
[   16.294522] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 s=
econds, margin is 60 seconds).
[   16.303473] Hangcheck: Using get_cycles().
[   16.307589] Serial: 8250/16550 driver $Revision: 1.90 $ 2 ports, IRQ=
 sharing enabled
[   16.315427] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   16.321699] serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[   16.328320] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   16.334423] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[   16.340612] loop: module loaded
[   16.343932] PPP generic driver version 2.4.2
[   16.348294] PPP Deflate Compression module registered
[   16.353361] PPP BSD Compression module registered
[   16.358151] PPP MPPE Compression module registered
[   16.363048] r8169 Gigabit Ethernet driver 2.2LK loaded
[   16.369027] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 10
[   16.374776] PCI: setting IRQ 10 as level-triggered
[   16.374784] ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [LNKC] -> GS=
I 10 (level, low) -> IRQ 10
[   16.383840] eth0: RTL8169sc/8110sc at 0xc080e000, 00:30:18:b0:25:c2,=
 XID 18000000 IRQ 10
[   16.392591] r8169 Gigabit Ethernet driver 2.2LK loaded
[   16.398497] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[   16.404246] PCI: setting IRQ 11 as level-triggered
[   16.404254] ACPI: PCI Interrupt 0000:00:0b.0[A] -> Link [LNKD] -> GS=
I 11 (level, low) -> IRQ 11
[   16.413265] eth1: RTL8169sc/8110sc at 0xc0810000, 00:30:18:b0:25:c3,=
 XID 18000000 IRQ 11
[   16.422037] netconsole: device eth0 not up yet, forcing it
[   16.427846] r8169: eth0: link down
[   19.176561] r8169: eth0: link up
[   19.194082] console [netcon0] enabled
[   20.216942] netconsole: network logging started
[   20.221483] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[   20.227843] ide: Assuming 33MHz system bus speed for PIO modes; over=
ride with idebus=3Dxx
[   20.235979] VP_IDE: IDE controller at PCI slot 0000:00:0f.0
[   20.242323] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 7
[   20.247995] PCI: setting IRQ 7 as level-triggered
[   20.248003] ACPI: PCI Interrupt 0000:00:0f.0[A] -> Link [LNKA] -> GS=
I 7 (level, low) -> IRQ 7
[   20.256586] PCI: VIA VLink IRQ fixup for 0000:00:0f.0, from 255 to 7
[   20.262973] VP_IDE: chipset revision 6
[   20.266733] VP_IDE: not 100% native mode: will probe irqs later
[   20.272666] VP_IDE: VIA vt8237 (rev 00) IDE UDMA133 controller on pc=
i0000:00:0f.0
[   20.280158]     ide0: BM-DMA at 0xff00-0xff07, BIOS settings: hda:DM=
A, hdb:pio
[   20.287445] Probing IDE interface ide0...
[   20.325031] Marking TSC unstable due to: possible TSC halt in C2.
[   20.331123] Time: acpi_pm clocksource has been installed.
[   20.704825] hda: WDC WD1200VE-00KWT0, ATA DISK drive
[   21.380151] hda: host side 80-wire cable detection failed, limiting =
max speed to UDMA33
[   21.388161] hda: selected mode 0x42
[   21.388250] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   21.393056] hda: max request size: 512KiB
[   21.455752] hda: 234441648 sectors (120034 MB) w/8192KiB Cache, CHS=3D=
16383/255/63, UDMA(33)
[   21.464184] hda: cache flushes supported
[   21.468161]  hda: hda1
[   21.477250] ACPI: PCI Interrupt 0000:00:10.4[C] -> Link [LNKC] -> GS=
I 10 (level, low) -> IRQ 10
[   21.486028] ehci_hcd 0000:00:10.4: EHCI Host Controller
[   21.491351] ehci_hcd 0000:00:10.4: new USB bus registered, assigned =
bus number 1
[   21.498815] ehci_hcd 0000:00:10.4: irq 10, io mem 0xfdffd000
[   21.504502] ehci_hcd 0000:00:10.4: USB 2.0 started, EHCI 1.00, drive=
r 10 Dec 2004
[   21.512249] usb usb1: configuration #1 chosen from 1 choice
[   21.517899] hub 1-0:1.0: USB hub found
[   21.521677] hub 1-0:1.0: 8 ports detected
[   21.628049] USB Universal Host Controller Interface driver v3.0
[   21.634108] ACPI: PCI Interrupt 0000:00:10.0[A] -> Link [LNKA] -> GS=
I 7 (level, low) -> IRQ 7
[   21.642712] uhci_hcd 0000:00:10.0: UHCI Host Controller
[   21.648005] uhci_hcd 0000:00:10.0: new USB bus registered, assigned =
bus number 2
[   21.655433] uhci_hcd 0000:00:10.0: irq 7, io base 0x0000fe00
[   21.661353] usb usb2: configuration #1 chosen from 1 choice
[   21.667011] hub 2-0:1.0: USB hub found
[   21.670797] hub 2-0:1.0: 2 ports detected
[   21.775890] ACPI: PCI Interrupt 0000:00:10.1[A] -> Link [LNKA] -> GS=
I 7 (level, low) -> IRQ 7
[   21.784482] uhci_hcd 0000:00:10.1: UHCI Host Controller
[   21.789773] uhci_hcd 0000:00:10.1: new USB bus registered, assigned =
bus number 3
[   21.797200] uhci_hcd 0000:00:10.1: irq 7, io base 0x0000fd00
[   21.803109] usb usb3: configuration #1 chosen from 1 choice
[   21.808762] hub 3-0:1.0: USB hub found
[   21.812536] hub 3-0:1.0: 2 ports detected
[   21.920560] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
[   21.926345] ACPI: PCI Interrupt 0000:00:10.2[B] -> Link [LNKB] -> GS=
I 11 (level, low) -> IRQ 11
[   21.935107] PCI: VIA VLink IRQ fixup for 0000:00:10.2, from 5 to 11
[   21.941404] uhci_hcd 0000:00:10.2: UHCI Host Controller
[   21.946735] uhci_hcd 0000:00:10.2: new USB bus registered, assigned =
bus number 4
[   21.954168] uhci_hcd 0000:00:10.2: irq 11, io base 0x0000fc00
[   21.960199] usb usb4: configuration #1 chosen from 1 choice
[   21.965859] hub 4-0:1.0: USB hub found
[   21.969637] hub 4-0:1.0: 2 ports detected
[   22.075619] ACPI: PCI Interrupt 0000:00:10.3[B] -> Link [LNKB] -> GS=
I 11 (level, low) -> IRQ 11
[   22.084399] PCI: VIA VLink IRQ fixup for 0000:00:10.3, from 5 to 11
[   22.090699] uhci_hcd 0000:00:10.3: UHCI Host Controller
[   22.095992] uhci_hcd 0000:00:10.3: new USB bus registered, assigned =
bus number 5
[   22.103425] uhci_hcd 0000:00:10.3: irq 11, io base 0x0000fb00
[   22.109415] usb usb5: configuration #1 chosen from 1 choice
[   22.115071] hub 5-0:1.0: USB hub found
[   22.118846] hub 5-0:1.0: 2 ports detected
[   22.139375] usb 2-1: new full speed USB device using uhci_hcd and ad=
dress 2
[   22.329683] usb 2-1: configuration #1 chosen from 1 choice
[   23.230391] usbcore: registered new interface driver usblp
[   23.235903] Initializing USB Mass Storage driver...
[   23.240875] usbcore: registered new interface driver usb-storage
[   23.246892] USB Mass Storage support registered.
[   23.251680] PNP: No PS/2 controller found. Probing ports directly.
[   23.506189] serio: i8042 KBD port at 0x60,0x64 irq 1
[   23.511290] mice: PS/2 mouse device common for all mice
[   23.516687] i2c /dev entries driver
[   23.520501] f71805f: Found F71805F/FG chip at 0x290, revision 19
[   23.918166] device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initiali=
sed: dm-devel@redhat.com
[   23.926741] padlock: Using VIA PadLock ACE for AES algorithm.
[   23.932501] padlock: Using VIA PadLock ACE for SHA1/SHA256 algorithm=
s.
[   23.939102] Advanced Linux Sound Architecture Driver Version 1.0.14 =
(Fri Jul 20 09:12:58 2007 UTC).
[   23.948323] ACPI: PCI Interrupt 0000:00:11.5[C] -> Link [LNKC] -> GS=
I 10 (level, low) -> IRQ 10
[   23.957225] PCI: Setting latency timer of device 0000:00:11.5 to 64
[   24.471419] ALSA device list:
[   24.474442]   #0: VIA 8237 with ALC655 at 0xf400, irq 10
[   24.479813] Netfilter messages via NETLINK v0.30.
[   24.484642] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   24.490812] ctnetlink v0.93: registering with nfnetlink.
[   24.496178] IPv4 over IPv4 tunneling driver
[   24.500581] GRE over IPv4 tunneling driver
[   24.505138] ip_tables: (C) 2000-2006 Netfilter Core Team
[   24.510561] ClusterIP Version 0.8 loaded successfully
[   24.515629] TCP bic registered
[   24.518695] TCP cubic registered
[   24.521934] TCP westwood registered
[   24.525431] TCP highspeed registered
[   24.529001] TCP hybla registered
[   24.532243] TCP htcp registered
[   24.535398] TCP vegas registered
[   24.538639] TCP veno registered
[   24.541790] TCP scalable registered
[   24.545287] TCP lp registered
[   24.548251] TCP yeah registered
[   24.551407] TCP illinois registered
[   24.554907] Initializing XFRM netlink socket
[   24.559235] NET: Registered protocol family 1
[   24.563686] NET: Registered protocol family 10
[   24.568252] lo: Disabled Privacy Extensions
[   24.572570] tunl0: Disabled Privacy Extensions
[   24.577102] Mobile IPv6
[   24.579595] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   24.585041] IPv6 over IPv4 tunneling driver
[   24.589473] sit0: Disabled Privacy Extensions
[   24.593998] NET: Registered protocol family 17
[   24.598469] NET: Registered protocol family 15
[   24.602979] Bridge firewalling registered
[   24.607005] Ebtables v2.0 registered
[   24.610618] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech=
=2Ecom>
[   24.617408] All bugs added by David S. Miller <davem@redhat.com>
[   24.623704] CPU0 - ACPI performance management activated.
[   24.629116]      *P0: 1500 MHz, 15000 mW, 10 =C2=B5s
[   24.633742]       P1: 800 MHz, 8000 mW, 10 =C2=B5s
[   24.638582] Using IPI Shortcut mode
[   24.689701] kjournald starting.  Commit interval 5 seconds
[   24.695233] EXT3-fs: mounted filesystem with ordered data mode.
[   24.701177] VFS: Mounted root (ext3 filesystem) readonly.
[   24.706864] Freeing unused kernel memory: 184k freed
[   24.712029] Write protecting the kernel text: 2596k
[   24.716975] Write protecting the kernel read-only data: 926k

--=20
Simon Arlott
