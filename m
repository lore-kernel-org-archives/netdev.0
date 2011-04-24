From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Kernel crash after using new Intel NIC (igb)
Date: Mon, 25 Apr 2011 00:32:59 +0200
Message-ID: <201104250033.03401.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7953574.IATS4ndeGM";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([178.77.99.65]:38189 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757789Ab1DXWlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2011 18:41:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart7953574.IATS4ndeGM
Content-Type: multipart/mixed;
  boundary="Boundary-01=_bUKtNuLEeCv9dQA"
Content-Transfer-Encoding: 7bit


--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

some time ago we switched some of our servers to a new networking card that=
=20
uses the Intel igb driver. Since that time we see regular kernel crashes.
The crashes happen at very irregular intervals, sometimes after a week upti=
me,=20
sometimes after a month or even more. They seem to be independent of the=20
server load as they also happen in the night when there is low traffic.

The affected server is used as a NAT device with some iptables rules and se=
rves=20
about 2000 people.

Attached are two logs of the crashes as well as the output of dmesg, lspci,=
=20
and /proc/interrupts as well as the used kernel config.

I have no idea what might be wrong but I think it is a kernel bug. Perhaps=
=20
someone with more knowledge has a clue.

If needed I can provide additional information or build different kernels.

Greetings,
Maxi

--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: text/plain;
  charset="UTF-8";
  name="crash1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="crash1"

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
PGD 12ec2f067 PUD 12f20e067 PMD 0
Oops: 0002 [#1] PREEMPT SMP
last sysfs file: /sys/devices/virtual/block/md1/md/mismatch_cnt
CPU 0
Pid: 0, comm: swapper Not tainted 2.6.37.1 #1 Supermicro X7SB4/E/X7SB4/E
RIP: 0010:[<ffffffff8145ea9f>]  [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
RSP: 0018:ffff8800cfc03e40  EFLAGS: 00010206
RAX: ffff8800c9f11cd8 RBX: ffff8800c9f11cc0 RCX: 0000000000000000
RDX: 3bcb79ae0002ced7 RSI: 000000000000017b RDI: ffffffff8166ce10
RBP: 00000000000247fc R08: 00000000003d0900 R09: 000ea506dd5a0400
R10: ffffffff814f312d R11: 0000000000000010 R12: ffffffff8161ffd8
R13: 0000000000000102 R14: ffffffff8174b4e0 R15: ffffffff8161ffd8
FS:  0000000000000000(0000) GS:ffff8800cfc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000012d94d000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8161e000, task ffffffff81638020)
Stack:
 ffff8800cfc11f00 000000013d6b69ec 00000000000247fc ffffffff8145ed68
 ffffffff8174a4c0 ffffffff8174a4c0 ffff8800cfc03eb0 ffffffff81044cb8
 ffffffff81034079 ffffffff8145ed30 0000000000000000 ffffffff8174b8e0
Call Trace:
 <IRQ>
 [<ffffffff8145ed68>] ? peer_check_expire+0x38/0x110
 [<ffffffff81044cb8>] ? run_timer_softirq+0x138/0x250
 [<ffffffff81034079>] ? scheduler_tick+0xd9/0x2e0
 [<ffffffff8145ed30>] ? peer_check_expire+0x0/0x110
 [<ffffffff8103eb0d>] ? __do_softirq+0x9d/0x130
 [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100531d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103e9cd>] ? irq_exit+0x8d/0x90
 [<ffffffff8101d5ea>] ? smp_apic_timer_interrupt+0x6a/0xa0
 [<ffffffff81002cd3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>
 [<ffffffff8100a93a>] ? mwait_idle+0x6a/0x80
 [<ffffffff81001528>] ? cpu_idle+0x58/0xb0
 [<ffffffff81698dd3>] ? start_kernel+0x334/0x33f
 [<ffffffff8169840d>] ? x86_64_start_kernel+0xf3/0xf7
Code: 00 48 8b 05 84 e3 20 00 48 3d 00 ce 66 81 74 5c 48 8d 58 e8 48 8b 15 31 5e 22 00 2b 53 28 48 39 ea 72 49 48 8b 4b 18 48 8b 53 20 <48> 89 51 08 48 89 0a 48 89 43 18 48 89 43 20 f0 ff 40 14 48 c7
RIP  [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
 RSP <ffff8800cfc03e40>
CR2: 0000000000000008
---[ end trace 9259bc3408260abc ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     2.6.37.1 #1
Call Trace:
 <IRQ>  [<ffffffff814e4152>] ? panic+0xa1/0x19e
 [<ffffffff810068eb>] ? oops_end+0x9b/0xa0
 [<ffffffff81024523>] ? no_context+0x103/0x270
 [<ffffffff81024d10>] ? do_page_fault+0x290/0x430
 [<ffffffff813f2b35>] ? netif_receive_skb+0x85/0x90
 [<ffffffff813f2d2c>] ? napi_gro_complete+0xbc/0x100
 [<ffffffff814e780f>] ? page_fault+0x1f/0x30
 [<ffffffff8145ea9f>] ? cleanup_once+0x3f/0xa0
 [<ffffffff8145ed68>] ? peer_check_expire+0x38/0x110
 [<ffffffff81044cb8>] ? run_timer_softirq+0x138/0x250
 [<ffffffff81034079>] ? scheduler_tick+0xd9/0x2e0
 [<ffffffff8145ed30>] ? peer_check_expire+0x0/0x110
 [<ffffffff8103eb0d>] ? __do_softirq+0x9d/0x130
 [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100531d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103e9cd>] ? irq_exit+0x8d/0x90
 [<ffffffff8101d5ea>] ? smp_apic_timer_interrupt+0x6a/0xa0
 [<ffffffff81002cd3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff8100a93a>] ? mwait_idle+0x6a/0x80
 [<ffffffff81001528>] ? cpu_idle+0x58/0xb0
 [<ffffffff81698dd3>] ? start_kernel+0x334/0x33f
 [<ffffffff8169840d>] ? x86_64_start_kernel+0xf3/0xf7


--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: text/plain;
  charset="UTF-8";
  name="crash2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="crash2"

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
PGD 12d82a067 PUD 12ea49067 PMD 0
Oops: 0002 [#1] PREEMPT SMP
last sysfs file: /sys/devices/virtual/vc/vcsa5/uevent
CPU 0
Pid: 0, comm: swapper Not tainted 2.6.37.1 #1 Supermicro X7SB4/E/X7SB4/E
RIP: 0010:[<ffffffff8145ea9f>]  [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
RSP: 0018:ffff8800cfc03e40  EFLAGS: 00010202
RAX: ffff880128167798 RBX: ffff880128167780 RCX: 0000000000000000
RDX: c398112e00026cf7 RSI: 00000000000001a2 RDI: ffffffff8166ce10
RBP: 0000000000024702 R08: 00000000003d0900 R09: 00040ea8ea5b7700
R10: ffffffff814f312d R11: 0000000000000010 R12: ffffffff8161ffd8
R13: 0000000000000102 R14: ffffffff8174b4e0 R15: ffffffff8161ffd8
FS:  0000000000000000(0000) GS:ffff8800cfc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000012fe67000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8161e000, task ffffffff81638020)
Stack:
 ffff8800cfc11f00 0000000111034f87 0000000000024702 ffffffff8145ed68
 ffffffff8174a4c0 ffffffff8174a4c0 ffff8800cfc03eb0 ffffffff81044cb8
 ffffffff81034079 ffffffff8145ed30 0000000000000000 ffffffff8174b8e0
Call Trace:
 <IRQ>
 [<ffffffff8145ed68>] ? peer_check_expire+0x38/0x110
 [<ffffffff81044cb8>] ? run_timer_softirq+0x138/0x250
 [<ffffffff81034079>] ? scheduler_tick+0xd9/0x2e0
 [<ffffffff8145ed30>] ? peer_check_expire+0x0/0x110
 [<ffffffff8103eb0d>] ? __do_softirq+0x9d/0x130
 [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100531d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103e9cd>] ? irq_exit+0x8d/0x90
 [<ffffffff8101d5ea>] ? smp_apic_timer_interrupt+0x6a/0xa0
 [<ffffffff81002cd3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>
 [<ffffffff8100a93a>] ? mwait_idle+0x6a/0x80
 [<ffffffff81001528>] ? cpu_idle+0x58/0xb0
 [<ffffffff81698dd3>] ? start_kernel+0x334/0x33f
 [<ffffffff8169840d>] ? x86_64_start_kernel+0xf3/0xf7
Code: 00 48 8b 05 84 e3 20 00 48 3d 00 ce 66 81 74 5c 48 8d 58 e8 48 8b 15 31 5e 22 00 2b 53 28 48 39 ea 72 49 48 8b 4b 18 48 8b 53 20 <48> 89 51 08 48 89 0a 48 89 43 18 48 89 43 20 f0 ff 40 14 48 c7
RIP  [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
 RSP <ffff8800cfc03e40>
CR2: 0000000000000008
---[ end trace 904f16191de0663c ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     2.6.37.1 #1
Call Trace:
 <IRQ>  [<ffffffff814e4152>] ? panic+0xa1/0x19e
 [<ffffffff810068eb>] ? oops_end+0x9b/0xa0
 [<ffffffff81024523>] ? no_context+0x103/0x270
 [<ffffffff81024d10>] ? do_page_fault+0x290/0x430
 [<ffffffff813eabd2>] ? __alloc_skb+0x72/0x160
 [<ffffffff81262f40>] ? swiotlb_dma_mapping_error+0x10/0x20
 [<ffffffff8133e168>] ? igb_alloc_rx_buffers_adv+0x208/0x3a0
 [<ffffffff814e780f>] ? page_fault+0x1f/0x30
 [<ffffffff8145ea9f>] ? cleanup_once+0x3f/0xa0
 [<ffffffff8145ed68>] ? peer_check_expire+0x38/0x110
 [<ffffffff81044cb8>] ? run_timer_softirq+0x138/0x250
 [<ffffffff81034079>] ? scheduler_tick+0xd9/0x2e0
 [<ffffffff8145ed30>] ? peer_check_expire+0x0/0x110
 [<ffffffff8103eb0d>] ? __do_softirq+0x9d/0x130
 [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100531d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103e9cd>] ? irq_exit+0x8d/0x90
 [<ffffffff8101d5ea>] ? smp_apic_timer_interrupt+0x6a/0xa0
 [<ffffffff81002cd3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff8100a93a>] ? mwait_idle+0x6a/0x80
 [<ffffffff81001528>] ? cpu_idle+0x58/0xb0
 [<ffffffff81698dd3>] ? start_kernel+0x334/0x33f
 [<ffffffff8169840d>] ? x86_64_start_kernel+0xf3/0xf7


--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: text/plain;
  charset="UTF-8";
  name="dmesg"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="dmesg"

Linux version 2.6.37.1 (a004477a@natter) (gcc version 4.4.5 (Debian 4.4.5-8=
) ) #1 SMP PREEMPT Tue Feb 22 02:20:57 CET 2011
Command line: BOOT_IMAGE=3D/vmlinuz-2.6.37.1 root=3D/dev/mapper/raid-root r=
o console=3DttyS0,115200 console=3Dtty0
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009cc00 (usable)
 BIOS-e820: 000000000009cc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000ce000 - 00000000000d0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cfe70000 (usable)
 BIOS-e820: 00000000cfe70000 - 00000000cfe7e000 (ACPI data)
 BIOS-e820: 00000000cfe7e000 - 00000000cfe81000 (ACPI NVS)
 BIOS-e820: 00000000cfe81000 - 00000000d0000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fed00000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
NX (Execute Disable) protection: active
DMI present.
DMI: Supermicro X7SB4/E/X7SB4/E, BIOS 1.2a       12/19/2008
e820 update range: 0000000000000000 - 0000000000010000 (usable) =3D=3D> (re=
served)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
No AGP bridge found
last_pfn =3D 0x130000 max_arch_pfn =3D 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-C7FFF write-protect
  C8000-DFFFF uncachable
  E0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 0D0000000 mask FF0000000 uncachable
  1 base 0E0000000 mask FE0000000 uncachable
  2 base 000000000 mask F00000000 write-back
  3 base 100000000 mask FE0000000 write-back
  4 base 120000000 mask FF0000000 write-back
  5 disabled
  6 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
e820 update range: 00000000d0000000 - 0000000100000000 (usable) =3D=3D> (re=
served)
last_pfn =3D 0xcfe70 max_arch_pfn =3D 0x400000000
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-00000000cfe70000
 0000000000 - 00cfe00000 page 2M
 00cfe00000 - 00cfe70000 page 4k
kernel direct mapping tables up to cfe70000 @ 1fffa000-20000000
init_memory_mapping: 0000000100000000-0000000130000000
 0100000000 - 0130000000 page 2M
kernel direct mapping tables up to 130000000 @ cfe6a000-cfe70000
RAMDISK: 37cc6000 - 37ff0000
ACPI: RSDP 00000000000f6530 00024 (v02 PTLTD )
ACPI: XSDT 00000000cfe7360b 000CC (v01 PTLTD  ? XSDT   06040000  LTP 000000=
00)
ACPI: FACP 00000000cfe7d323 000F4 (v03 INTEL           06040000 PTL  000000=
02)
ACPI: DSDT 00000000cfe76e08 064A7 (v01  INTEL BEARLAKE 06040000 MSFT 030000=
01)
ACPI: FACS 00000000cfe80fc0 00040
ACPI: _MAR 00000000cfe7d417 0012F (v01 Intel  OEMDMAR  06040000 LOHR 000000=
01)
ACPI: MCFG 00000000cfe7d546 0003C (v01 PTLTD    MCFG   06040000  LTP 000000=
00)
ACPI: HPET 00000000cfe7d582 00038 (v01 PTLTD  HPETTBL  06040000  LTP 000000=
01)
ACPI: APIC 00000000cfe7d5ba 00080 (v01 PTLTD  ? APIC   06040000  LTP 000000=
00)
ACPI: BOOT 00000000cfe7d63a 00028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 000000=
01)
ACPI: SPCR 00000000cfe7d662 00050 (v01 PTLTD  $UCRTBL$ 06040000 PTL  000000=
01)
ACPI: ERST 00000000cfe7d6b2 00590 (v01 SMCI   ERSTTBL  06040000 SMCI 000000=
01)
ACPI: HEST 00000000cfe7dc42 000A8 (v01 SMCI   HESTTBL  06040000 SMCI 000000=
01)
ACPI: BERT 00000000cfe7dcea 00030 (v01 SMCI   BERTTBL  06040000 SMCI 000000=
01)
ACPI: EINJ 00000000cfe7dd1a 00170 (v01 SMCI   EINJTBL  06040000 SMCI 000000=
01)
ACPI: SLIC 00000000cfe7de8a 00176 (v01 OEMID_ OEMTABLE 06040000  LTP 000000=
00)
ACPI: SSDT 00000000cfe74f4a 0025F (v01  PmRef  Cpu0Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74ea4 000A6 (v01  PmRef  Cpu7Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74dfe 000A6 (v01  PmRef  Cpu6Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74d58 000A6 (v01  PmRef  Cpu5Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74cb2 000A6 (v01  PmRef  Cpu4Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74c0c 000A6 (v01  PmRef  Cpu3Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74b66 000A6 (v01  PmRef  Cpu2Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe74ac0 000A6 (v01  PmRef  Cpu1Tst 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe736d7 013E9 (v01  PmRef    CpuPm 00003000 INTL 200502=
28)
ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea00043fffff] PMD -> [ffff8800c0000000-ffff8800c39ff=
fff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00130000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009c
    0: 0x00000100 -> 0x000cfe70
    0: 0x00100000 -> 0x00130000
On node 0 totalpages: 1048060
  DMA zone: 56 pages used for memmap
  DMA zone: 2 pages reserved
  DMA zone: 3922 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 833192 pages, LIFO batch:31
  Normal zone: 2688 pages used for memmap
  Normal zone: 193920 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x1008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x03] address[0xfecc0000] gsi_base[24])
IOAPIC[1]: apic_id 3, version 32, address 0xfecc0000, GSI 24-47
ACPI: IOAPIC (id[0x04] address[0xfecc0400] gsi_base[48])
IOAPIC[2]: apic_id 4, version 32, address 0xfecc0400, GSI 48-71
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0xffffffff base: 0xfed00000
SMP: Allowing 2 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 88
Allocating PCI resources starting at d0000000 (gap: d0000000:10000000)
setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
PERCPU: Embedded 24 pages/cpu @ffff8800cfc00000 s74048 r0 d24256 u1048576
pcpu-alloc: s74048 r0 d24256 u1048576 alloc=3D1*2097152
pcpu-alloc: [0] 0 1=20
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1031034
Kernel command line: BOOT_IMAGE=3D/vmlinuz-2.6.37.1 root=3D/dev/mapper/raid=
=2Droot ro console=3DttyS0,115200 console=3Dtty0
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
xsave/xrstor: enabled xstate_bv 0x3, cntxt size 0x240
Checking aperture...
No AGP bridge found
Memory: 4049508k/4980736k available (5031k kernel code, 788496k absent, 142=
732k reserved, 1636k data, 452k init)
SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, N=
odes=3D1
Preemptable hierarchical RCU implementation.
	RCU-based detection of stalled CPUs is disabled.
	Verbose stalled-CPUs detection is disabled.
NR_IRQS:320
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [tty0] enabled
console [ttyS0] enabled
hpet clockevent registered
=46ast TSC calibration using PIT
Detected 2992.591 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. =
5985.18 BogoMIPS (lpj=3D11970364)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 256
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
CPU0: Thermal monitoring handled by SMI
using mwait in idle threads.
Performance Events: PEBS fmt0+, Core2 events, Intel PMU driver.
=2E.. version:                2
=2E.. bit width:              40
=2E.. generic registers:      2
=2E.. value mask:             000000ffffffffff
=2E.. max period:             000000007fffffff
=2E.. fixed-purpose events:   3
=2E.. event mask:             0000000700000003
ACPI: Core revision 20101013
Setting APIC routing to flat
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
CPU0: Intel(R) Xeon(R) CPU           E3110  @ 3.00GHz stepping 0a
Booting Node   0, Processors  #1 Ok.
CPU1: Thermal monitoring handled by SMI
Brought up 2 CPUs
Total of 2 processors activated (11970.15 BogoMIPS).
NET: Registered protocol family 16
ACPI: bus type pci registered
dca service started, version 1.12.1
PCI: MMCONFIG for domain 0000 [bus 00-10] at [mem 0xe0000000-0xe10fffff] (b=
ase 0xe0000000)
PCI: MMCONFIG at [mem 0xe0000000-0xe10fffff] reserved in E820
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
\_SB_:_OSC evaluation returned wrong type
_OSC request data:1 7=20
ACPI: SSDT 00000000cfe751a9 00261 (v01  PmRef  Cpu0Ist 00003000 INTL 200502=
28)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 00261 (v01  PmRef  Cpu0Ist 00003000 INTL 200502=
28)
ACPI: SSDT 00000000cfe7540a 001F2 (v01  PmRef  Cpu1Ist 00003000 INTL 200502=
28)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 001F2 (v01  PmRef  Cpu1Ist 00003000 INTL 200502=
28)
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI: No dock devices found.
PCI: Using host bridge windows from ACPI; if necessary, use "pci=3Dnocrs" a=
nd report a bug
\_SB_.PCI0:_OSC evaluation returned wrong type
_OSC request data:1 8 1f=20
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3f])
pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A03:00: host bridge window [mem 0x000d0000-0x000d3fff]
pci_root PNP0A03:00: host bridge window [mem 0x000d4000-0x000d7fff]
pci_root PNP0A03:00: host bridge window [mem 0x000d8000-0x000dbfff]
pci_root PNP0A03:00: host bridge window [mem 0x000dc000-0x000dffff]
pci_root PNP0A03:00: host bridge window [mem 0xd0000000-0xdfffffff]
pci_root PNP0A03:00: host bridge window [io  0x0d00-0xfdff]
pci 0000:00:00.0: [8086:29f0] type 0 class 0x000600
pci 0000:00:01.0: [8086:29f1] type 1 class 0x000604
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:1a.0: [8086:2937] type 0 class 0x000c03
pci 0000:00:1a.0: reg 20: [io  0x1820-0x183f]
pci 0000:00:1a.1: [8086:2938] type 0 class 0x000c03
pci 0000:00:1a.1: reg 20: [io  0x1840-0x185f]
pci 0000:00:1a.2: [8086:2939] type 0 class 0x000c03
pci 0000:00:1a.2: reg 20: [io  0x1860-0x187f]
pci 0000:00:1a.7: [8086:293c] type 0 class 0x000c03
pci 0000:00:1a.7: reg 10: [mem 0xd0000000-0xd00003ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1c.0: [8086:2940] type 1 class 0x000604
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.4: [8086:2948] type 1 class 0x000604
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: [8086:294a] type 1 class 0x000604
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.0: [8086:2934] type 0 class 0x000c03
pci 0000:00:1d.0: reg 20: [io  0x1880-0x189f]
pci 0000:00:1d.1: [8086:2935] type 0 class 0x000c03
pci 0000:00:1d.1: reg 20: [io  0x18a0-0x18bf]
pci 0000:00:1d.2: [8086:2936] type 0 class 0x000c03
pci 0000:00:1d.2: reg 20: [io  0x18c0-0x18df]
pci 0000:00:1d.7: [8086:293a] type 0 class 0x000c03
pci 0000:00:1d.7: reg 10: [mem 0xd0000400-0xd00007ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1e.0: [8086:244e] type 1 class 0x000604
pci 0000:00:1f.0: [8086:2916] type 0 class 0x000601
pci 0000:00:1f.0: quirk: [io  0x1000-0x107f] claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: [io  0x1180-0x11bf] claimed by ICH6 GPIO
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0290 (mask 0097)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 00af)
pci 0000:00:1f.2: [8086:2922] type 0 class 0x000106
pci 0000:00:1f.2: reg 10: [io  0x1c50-0x1c57]
pci 0000:00:1f.2: reg 14: [io  0x1c44-0x1c47]
pci 0000:00:1f.2: reg 18: [io  0x1c48-0x1c4f]
pci 0000:00:1f.2: reg 1c: [io  0x1c40-0x1c43]
pci 0000:00:1f.2: reg 20: [io  0x18e0-0x18ff]
pci 0000:00:1f.2: reg 24: [mem 0xd0000800-0xd0000fff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: [8086:2930] type 0 class 0x000c05
pci 0000:00:1f.3: reg 10: [mem 0xd0001000-0xd00010ff 64bit]
pci 0000:00:1f.3: reg 20: [io  0x1100-0x111f]
pci 0000:00:1f.6: [8086:2932] type 0 class 0x001180
pci 0000:00:1f.6: reg 10: [mem 0xd0002000-0xd0002fff 64bit]
pci 0000:01:00.0: [8086:0329] type 1 class 0x000604
pci 0000:01:00.0: PXH quirk detected; SHPC device MSI disabled
pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
pci 0000:01:00.0: PME# disabled
pci 0000:01:00.1: [8086:0326] type 0 class 0x000800
pci 0000:01:00.1: reg 10: [mem 0xd0100000-0xd0100fff]
pci 0000:01:00.2: [8086:032a] type 1 class 0x000604
pci 0000:01:00.2: PXH quirk detected; SHPC device MSI disabled
pci 0000:01:00.2: PME# supported from D0 D3hot D3cold
pci 0000:01:00.2: PME# disabled
pci 0000:01:00.3: [8086:0327] type 0 class 0x000800
pci 0000:01:00.3: reg 10: [mem 0xd0101000-0xd0101fff]
pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it=
 with 'pcie_aspm=3Dforce'
pci 0000:00:01.0: PCI bridge to [bus 01-03]
pci 0000:00:01.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:01.0:   bridge window [mem 0xd0100000-0xd01fffff]
pci 0000:00:01.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disable=
d)
pci 0000:01:00.0: PCI bridge to [bus 02-02]
pci 0000:01:00.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:01:00.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:01:00.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disable=
d)
pci 0000:01:00.2: PCI bridge to [bus 03-03]
pci 0000:01:00.2:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:01:00.2:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:01:00.2:   bridge window [mem 0xfff00000-0x000fffff pref] (disable=
d)
pci 0000:05:00.0: [8086:10c9] type 0 class 0x000200
pci 0000:05:00.0: reg 10: [mem 0xd0220000-0xd023ffff]
pci 0000:05:00.0: reg 14: [mem 0xd0400000-0xd07fffff]
pci 0000:05:00.0: reg 18: [io  0x2000-0x201f]
pci 0000:05:00.0: reg 1c: [mem 0xd0200000-0xd0203fff]
pci 0000:05:00.0: reg 30: [mem 0x00000000-0x003fffff pref]
pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
pci 0000:05:00.0: PME# disabled
pci 0000:05:00.1: [8086:10c9] type 0 class 0x000200
pci 0000:05:00.1: reg 10: [mem 0xd0240000-0xd025ffff]
pci 0000:05:00.1: reg 14: [mem 0xd0800000-0xd0bfffff]
pci 0000:05:00.1: reg 18: [io  0x2020-0x203f]
pci 0000:05:00.1: reg 1c: [mem 0xd0204000-0xd0207fff]
pci 0000:05:00.1: reg 30: [mem 0x00000000-0x003fffff pref]
pci 0000:05:00.1: PME# supported from D0 D3hot D3cold
pci 0000:05:00.1: PME# disabled
pci 0000:00:1c.0: PCI bridge to [bus 05-05]
pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
pci 0000:00:1c.0:   bridge window [mem 0xd0200000-0xd0bfffff]
pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disable=
d)
pci 0000:0d:00.0: [8086:108c] type 0 class 0x000200
pci 0000:0d:00.0: reg 10: [mem 0xd0c00000-0xd0c1ffff]
pci 0000:0d:00.0: reg 18: [io  0x3000-0x301f]
pci 0000:0d:00.0: PME# supported from D0 D3hot D3cold
pci 0000:0d:00.0: PME# disabled
pci 0000:0d:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it=
 with 'pcie_aspm=3Dforce'
pci 0000:00:1c.4: PCI bridge to [bus 0d-0d]
pci 0000:00:1c.4:   bridge window [io  0x3000-0x3fff]
pci 0000:00:1c.4:   bridge window [mem 0xd0c00000-0xd0cfffff]
pci 0000:00:1c.4:   bridge window [mem 0xfff00000-0x000fffff pref] (disable=
d)
pci 0000:0f:00.0: [8086:109a] type 0 class 0x000200
pci 0000:0f:00.0: reg 10: [mem 0xd0d00000-0xd0d1ffff]
pci 0000:0f:00.0: reg 18: [io  0x4000-0x401f]
pci 0000:0f:00.0: PME# supported from D0 D3hot D3cold
pci 0000:0f:00.0: PME# disabled
pci 0000:0f:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it=
 with 'pcie_aspm=3Dforce'
pci 0000:00:1c.5: PCI bridge to [bus 0f-0f]
pci 0000:00:1c.5:   bridge window [io  0x4000-0x4fff]
pci 0000:00:1c.5:   bridge window [mem 0xd0d00000-0xd0dfffff]
pci 0000:00:1c.5:   bridge window [mem 0xfff00000-0x000fffff pref] (disable=
d)
pci 0000:11:04.0: [1002:515e] type 0 class 0x000300
pci 0000:11:04.0: reg 10: [mem 0xd8000000-0xdfffffff pref]
pci 0000:11:04.0: reg 14: [io  0x5000-0x50ff]
pci 0000:11:04.0: reg 18: [mem 0xd0e00000-0xd0e0ffff]
pci 0000:11:04.0: reg 30: [mem 0x00000000-0x0001ffff pref]
pci 0000:11:04.0: supports D1 D2
pci 0000:00:1e.0: PCI bridge to [bus 11-11] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x5000-0x5fff]
pci 0000:00:1e.0:   bridge window [mem 0xd0e00000-0xd0efffff]
pci 0000:00:1e.0:   bridge window [mem 0xd8000000-0xdfffffff 64bit pref]
pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive =
decode)
pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000d3fff] (subtractive =
decode)
pci 0000:00:1e.0:   bridge window [mem 0x000d4000-0x000d7fff] (subtractive =
decode)
pci 0000:00:1e.0:   bridge window [mem 0x000d8000-0x000dbfff] (subtractive =
decode)
pci 0000:00:1e.0:   bridge window [mem 0x000dc000-0x000dffff] (subtractive =
decode)
pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xdfffffff] (subtractive =
decode)
pci 0000:00:1e.0:   bridge window [io  0x0d00-0xfdff] (subtractive decode)
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEG_.PXHA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEG_.PXHB._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
\_SB_.PCI0:_OSC evaluation returned wrong type
_OSC request data:1 1f 1f=20
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disable=
d.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disable=
d.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disable=
d.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
vgaarb: device added: PCI:0000:11:04.0,decodes=3Dio+mem,owns=3Dio+mem,locks=
=3Dnone
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
reserve RAM buffer: 000000000009cc00 - 000000000009ffff=20
reserve RAM buffer: 00000000cfe70000 - 00000000cfffffff=20
HPET: 4 timers in total, 0 timers will be used for per-cpu timer
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 64-bit 14.318180 MHz counter
Switching to clocksource tsc
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [bus 00-3f]
pnp 00:00: [io  0x0cf8-0x0cff]
pnp 00:00: [io  0x0000-0x0cf7 window]
pnp 00:00: [mem 0x000a0000-0x000bffff window]
pnp 00:00: [mem 0x000c0000-0x000c3fff window]
pnp 00:00: [mem 0x000c4000-0x000c7fff window]
pnp 00:00: [mem 0x000c8000-0x000cbfff window]
pnp 00:00: [mem 0x000cc000-0x000cffff window]
pnp 00:00: [mem 0x000d0000-0x000d3fff window]
pnp 00:00: [mem 0x000d4000-0x000d7fff window]
pnp 00:00: [mem 0x000d8000-0x000dbfff window]
pnp 00:00: [mem 0x000dc000-0x000dffff window]
pnp 00:00: [mem 0x000e0000-0x000e3fff window]
pnp 00:00: [mem 0x000e4000-0x000e7fff window]
pnp 00:00: [mem 0x000e8000-0x000ebfff window]
pnp 00:00: [mem 0x000ec000-0x000effff window]
pnp 00:00: [mem 0x000f0000-0x000fffff window]
pnp 00:00: [mem 0xd0000000-0xdfffffff window]
pnp 00:00: [io  0x0d00-0xfdff window]
pnp 00:00: [mem 0x00000000 window]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:01: [io  0x0010-0x001f]
pnp 00:01: [io  0x0024-0x0025]
pnp 00:01: [io  0x0028-0x0029]
pnp 00:01: [io  0x002c-0x002d]
pnp 00:01: [io  0x002e-0x002f]
pnp 00:01: [io  0x0030-0x0031]
pnp 00:01: [io  0x0034-0x0035]
pnp 00:01: [io  0x0038-0x0039]
pnp 00:01: [io  0x003c-0x003d]
pnp 00:01: [io  0x0072-0x0077]
pnp 00:01: [io  0x0080]
pnp 00:01: [io  0x0090-0x009f]
pnp 00:01: [io  0x00a4-0x00a5]
pnp 00:01: [io  0x00a8-0x00a9]
pnp 00:01: [io  0x00ac-0x00ad]
pnp 00:01: [io  0x00b0-0x00b5]
pnp 00:01: [io  0x00b8-0x00b9]
pnp 00:01: [io  0x00bc-0x00bd]
pnp 00:01: [io  0x0295-0x0296]
pnp 00:01: [io  0x0800-0x080f]
pnp 00:01: [io  0x1000-0x107f]
pnp 00:01: [io  0x1180-0x11bf]
pnp 00:01: [io  0x04d0-0x04d1]
pnp 00:01: [io  0xfe00]
pnp 00:01: [mem 0xfed14000-0xfed17fff]
pnp 00:01: [mem 0xe0000000-0xefffffff]
pnp 00:01: [mem 0xfef00000-0xfeffffff]
pnp 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:02: [io  0x0000-0x000f]
pnp 00:02: [io  0x0081-0x008f]
pnp 00:02: [io  0x00c0-0x00df]
pnp 00:02: [dma 4]
pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:03: [io  0x00f0-0x00fe]
pnp 00:03: [irq 13]
pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:04: [irq 0 disabled]
pnp 00:04: [irq 8]
pnp 00:04: [mem 0xfed00000-0xfed003ff]
pnp 00:04: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:05: [io  0x0070-0x0071]
pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:06: [io  0x0061]
pnp 00:06: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:07: [mem 0xff800000-0xffffffff]
pnp 00:07: Plug and Play ACPI device, IDs INT0800 (active)
pnp 00:08: [io  0x0060]
pnp 00:08: [io  0x0064]
pnp 00:08: [irq 1]
pnp 00:08: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
pnp 00:09: [irq 12]
pnp 00:09: Plug and Play ACPI device, IDs PNP0f13 (active)
pnp 00:0a: [io  0x03f8-0x03ff]
pnp 00:0a: [irq 4]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0b: [io  0x02f8-0x02ff]
pnp 00:0b: [irq 3]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0c: [io  0x03f0-0x03f5]
pnp 00:0c: [io  0x03f7]
pnp 00:0c: [irq 6]
pnp 00:0c: [dma 2]
pnp 00:0c: Plug and Play ACPI device, IDs PNP0700 (active)
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: [io  0x0295-0x0296] has been reserved
system 00:01: [io  0x0800-0x080f] has been reserved
system 00:01: [io  0x1000-0x107f] has been reserved
system 00:01: [io  0x1180-0x11bf] has been reserved
system 00:01: [io  0x04d0-0x04d1] has been reserved
system 00:01: [io  0xfe00] has been reserved
system 00:01: [mem 0xfed14000-0xfed17fff] has been reserved
system 00:01: [mem 0xe0000000-0xefffffff] has been reserved
system 00:01: [mem 0xfef00000-0xfeffffff] has been reserved
pci 0000:00:1c.0: BAR 9: assigned [mem 0xd1000000-0xd17fffff pref]
pci 0000:00:1c.4: BAR 9: assigned [mem 0xd1800000-0xd19fffff 64bit pref]
pci 0000:00:1c.5: BAR 9: assigned [mem 0xd1a00000-0xd1bfffff 64bit pref]
pci 0000:01:00.0: PCI bridge to [bus 02-02]
pci 0000:01:00.0:   bridge window [io  disabled]
pci 0000:01:00.0:   bridge window [mem disabled]
pci 0000:01:00.0:   bridge window [mem pref disabled]
pci 0000:01:00.2: PCI bridge to [bus 03-03]
pci 0000:01:00.2:   bridge window [io  disabled]
pci 0000:01:00.2:   bridge window [mem disabled]
pci 0000:01:00.2:   bridge window [mem pref disabled]
pci 0000:00:01.0: PCI bridge to [bus 01-03]
pci 0000:00:01.0:   bridge window [io  disabled]
pci 0000:00:01.0:   bridge window [mem 0xd0100000-0xd01fffff]
pci 0000:00:01.0:   bridge window [mem pref disabled]
pci 0000:05:00.0: BAR 6: assigned [mem 0xd1000000-0xd13fffff pref]
pci 0000:05:00.1: BAR 6: assigned [mem 0xd1400000-0xd17fffff pref]
pci 0000:00:1c.0: PCI bridge to [bus 05-05]
pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
pci 0000:00:1c.0:   bridge window [mem 0xd0200000-0xd0bfffff]
pci 0000:00:1c.0:   bridge window [mem 0xd1000000-0xd17fffff pref]
pci 0000:00:1c.4: PCI bridge to [bus 0d-0d]
pci 0000:00:1c.4:   bridge window [io  0x3000-0x3fff]
pci 0000:00:1c.4:   bridge window [mem 0xd0c00000-0xd0cfffff]
pci 0000:00:1c.4:   bridge window [mem 0xd1800000-0xd19fffff 64bit pref]
pci 0000:00:1c.5: PCI bridge to [bus 0f-0f]
pci 0000:00:1c.5:   bridge window [io  0x4000-0x4fff]
pci 0000:00:1c.5:   bridge window [mem 0xd0d00000-0xd0dfffff]
pci 0000:00:1c.5:   bridge window [mem 0xd1a00000-0xd1bfffff 64bit pref]
pci 0000:11:04.0: BAR 6: assigned [mem 0xd0e20000-0xd0e3ffff pref]
pci 0000:00:1e.0: PCI bridge to [bus 11-11]
pci 0000:00:1e.0:   bridge window [io  0x5000-0x5fff]
pci 0000:00:1e.0:   bridge window [mem 0xd0e00000-0xd0efffff]
pci 0000:00:1e.0:   bridge window [mem 0xd8000000-0xdfffffff 64bit pref]
pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:01.0: setting latency timer to 64
pci 0000:01:00.0: setting latency timer to 64
pci 0000:01:00.2: setting latency timer to 64
pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:00:1c.4: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.4: setting latency timer to 64
pci 0000:00:1c.5: PCI INT B -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.5: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:00: resource 5 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 6 [mem 0x000d0000-0x000d3fff]
pci_bus 0000:00: resource 7 [mem 0x000d4000-0x000d7fff]
pci_bus 0000:00: resource 8 [mem 0x000d8000-0x000dbfff]
pci_bus 0000:00: resource 9 [mem 0x000dc000-0x000dffff]
pci_bus 0000:00: resource 10 [mem 0xd0000000-0xdfffffff]
pci_bus 0000:00: resource 11 [io  0x0d00-0xfdff]
pci_bus 0000:01: resource 1 [mem 0xd0100000-0xd01fffff]
pci_bus 0000:05: resource 0 [io  0x2000-0x2fff]
pci_bus 0000:05: resource 1 [mem 0xd0200000-0xd0bfffff]
pci_bus 0000:05: resource 2 [mem 0xd1000000-0xd17fffff pref]
pci_bus 0000:0d: resource 0 [io  0x3000-0x3fff]
pci_bus 0000:0d: resource 1 [mem 0xd0c00000-0xd0cfffff]
pci_bus 0000:0d: resource 2 [mem 0xd1800000-0xd19fffff 64bit pref]
pci_bus 0000:0f: resource 0 [io  0x4000-0x4fff]
pci_bus 0000:0f: resource 1 [mem 0xd0d00000-0xd0dfffff]
pci_bus 0000:0f: resource 2 [mem 0xd1a00000-0xd1bfffff 64bit pref]
pci_bus 0000:11: resource 0 [io  0x5000-0x5fff]
pci_bus 0000:11: resource 1 [mem 0xd0e00000-0xd0efffff]
pci_bus 0000:11: resource 2 [mem 0xd8000000-0xdfffffff 64bit pref]
pci_bus 0000:11: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:11: resource 5 [mem 0x000a0000-0x000bffff]
pci_bus 0000:11: resource 6 [mem 0x000d0000-0x000d3fff]
pci_bus 0000:11: resource 7 [mem 0x000d4000-0x000d7fff]
pci_bus 0000:11: resource 8 [mem 0x000d8000-0x000dbfff]
pci_bus 0000:11: resource 9 [mem 0x000dc000-0x000dffff]
pci_bus 0000:11: resource 10 [mem 0xd0000000-0xdfffffff]
pci_bus 0000:11: resource 11 [io  0x0d00-0xfdff]
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
UDP hash table entries: 2048 (order: 4, 65536 bytes)
UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
NET: Registered protocol family 1
PCI: CLS mismatch (32 !=3D 64), using 64 bytes
pci 0000:11:04.0: Boot video device
Unpacking initramfs...
=46reeing initrd memory: 3240k freed
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff8800cb600000 - ffff8800cf600000
software IO TLB at phys 0xcb600000 - 0xcf600000
Simple Boot Flag at 0x36 set to 0x1
NTFS driver 2.1.29 [Flags: R/W].
Btrfs loaded
msgmni has been set to 7915
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
\_SB_.PCI0:_OSC evaluation returned wrong type
_OSC request data:1 0 15=20
\_SB_.PCI0:_OSC evaluation returned wrong type
_OSC request data:1 0 15=20
\_SB_.PCI0:_OSC evaluation returned wrong type
_OSC request data:1 0 15=20
\_SB_.PCI0:_OSC evaluation returned wrong type
_OSC request data:1 0 15=20
intel_idle: MWAIT substates: 0x22220
intel_idle: does not run on family 6 model 23
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0A03:00/PNP0C0C:00=
/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: acpi_idle registered with cpuidle
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
00:0a: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
00:0b: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
loop: module loaded
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ahci 0000:00:1f.2: irq 88 for MSI/MSI-X
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mo=
de
ahci 0000:00:1f.2: flags: 64bit ncq sntf led clo pmp pio slum part ccc ems =
sxs=20
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xd0000800 port 0xd0000900 irq 88
ata2: SATA max UDMA/133 abar m2048@0xd0000800 port 0xd0000980 irq 88
ata3: SATA max UDMA/133 abar m2048@0xd0000800 port 0xd0000a00 irq 88
ata4: SATA max UDMA/133 abar m2048@0xd0000800 port 0xd0000a80 irq 88
ata5: SATA max UDMA/133 abar m2048@0xd0000800 port 0xd0000b00 irq 88
ata6: SATA max UDMA/133 abar m2048@0xd0000800 port 0xd0000b80 irq 88
e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
e1000: Copyright (c) 1999-2006 Intel Corporation.
e1000e: Intel(R) PRO/1000 Network Driver - 1.2.7-k2
e1000e: Copyright (c) 1999 - 2010 Intel Corporation.
e1000e 0000:0d:00.0: Disabling ASPM  L1
e1000e 0000:0d:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
e1000e 0000:0d:00.0: setting latency timer to 64
e1000e 0000:0d:00.0: irq 89 for MSI/MSI-X
e1000e 0000:0d:00.0: Disabling ASPM L0s=20
e1000e 0000:0d:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:30:48:d5:ba:3e
e1000e 0000:0d:00.0: eth0: Intel(R) PRO/1000 Network Connection
e1000e 0000:0d:00.0: eth0: MAC: 2, PHY: 2, PBA No: 0100ff-0ff
e1000e 0000:0f:00.0: Disabling ASPM  L1
e1000e 0000:0f:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
e1000e 0000:0f:00.0: setting latency timer to 64
e1000e 0000:0f:00.0: irq 90 for MSI/MSI-X
e1000e 0000:0f:00.0: Disabling ASPM L0s=20
e1000e 0000:0f:00.0: eth1: (PCI Express:2.5GB/s:Width x1) 00:30:48:d5:ba:3f
e1000e 0000:0f:00.0: eth1: Intel(R) PRO/1000 Network Connection
ata6: SATA link down (SStatus 0 SControl 300)
ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata3: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata1.00: ATA-6: WDC WD3200SD-01KNB0, 08.05J08, max UDMA/100
ata1.00: 625142448 sectors, multi 0: LBA48=20
ata5.00: ATA-7: SAMSUNG HE322HJ, 1AC01111, max UDMA7
ata5.00: 625142448 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata1.00: configured for UDMA/100
scsi 0:0:0:0: Direct-Access     ATA      WDC WD3200SD-01K 08.0 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 625142448 512-byte logical blocks: (320 GB/298 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
 sda: sda1 sda2
ata5.00: configured for UDMA/133
e1000e 0000:0f:00.0: eth1: MAC: 2, PHY: 2, PBA No: ffffff-0ff
Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
Copyright (c) 2007-2009 Intel Corporation.
igb 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
igb 0000:05:00.0: setting latency timer to 64
igb 0000:05:00.0: irq 91 for MSI/MSI-X
igb 0000:05:00.0: irq 92 for MSI/MSI-X
igb 0000:05:00.0: irq 93 for MSI/MSI-X
igb 0000:05:00.0: irq 94 for MSI/MSI-X
igb 0000:05:00.0: irq 95 for MSI/MSI-X
sd 0:0:0:0: [sda] Attached SCSI disk
igb 0000:05:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:05:00.0: eth2: (PCIe:2.5Gb/s:Width x4) 00:1b:21:8e:d4:2a
igb 0000:05:00.0: eth2: PBA No: e43709-005
igb 0000:05:00.0: Using MSI-X interrupts. 2 rx queue(s), 2 tx queue(s)
igb 0000:05:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
igb 0000:05:00.1: setting latency timer to 64
igb 0000:05:00.1: irq 96 for MSI/MSI-X
igb 0000:05:00.1: irq 97 for MSI/MSI-X
igb 0000:05:00.1: irq 98 for MSI/MSI-X
igb 0000:05:00.1: irq 99 for MSI/MSI-X
igb 0000:05:00.1: irq 100 for MSI/MSI-X
ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata4.00: ATAPI: CD-224E-R, 1.CA, max UDMA/33
ata4.00: configured for UDMA/33
igb 0000:05:00.1: Intel(R) Gigabit Ethernet Network Connection
igb 0000:05:00.1: eth3: (PCIe:2.5Gb/s:Width x4) 00:1b:21:8e:d4:2b
igb 0000:05:00.1: eth3: PBA No: e43709-005
igb 0000:05:00.1: Using MSI-X interrupts. 2 rx queue(s), 2 tx queue(s)
e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
ehci_hcd 0000:00:1a.7: cache line size of 64 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xd0000000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=3D1d6b, idProduct=3D0002
usb usb1: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.37.1 ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.7
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xd0000400
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=3D1d6b, idProduct=3D0002
scsi 3:0:0:0: CD-ROM            TEAC     CD-224E-R        1.CA PQ: 0 ANSI: 5
usb usb2: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.37.1 ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.7
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x00001820
usb usb3: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb3: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.37.1 uhci_hcd
usb usb3: SerialNumber: 0000:00:1a.0
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 17, io base 0x00001840
usb usb4: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb4: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.37.1 uhci_hcd
usb usb4: SerialNumber: 0000:00:1a.1
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
uhci_hcd 0000:00:1a.2: irq 18, io base 0x00001860
usb usb5: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb5: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.37.1 uhci_hcd
usb usb5: SerialNumber: 0000:00:1a.2
cdrom: Uniform CD-ROM driver Revision: 3.20
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
sr 3:0:0:0: Attached scsi CD-ROM sr0
scsi 4:0:0:0: Direct-Access     ATA      SAMSUNG HE322HJ  1AC0 PQ: 0 ANSI: 5
sd 4:0:0:0: [sdb] 625142448 512-byte logical blocks: (320 GB/298 GiB)
sd 4:0:0:0: [sdb] Write Protect is off
sd 4:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
 sdb: sdb1 sdb2
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
sd 4:0:0:0: [sdb] Attached SCSI disk
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x00001880
usb usb6: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb6: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb6: Product: UHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.37.1 uhci_hcd
usb usb6: SerialNumber: 0000:00:1d.0
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 22 (level, low) -> IRQ 22
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 22, io base 0x000018a0
usb usb7: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb7: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb7: Product: UHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.37.1 uhci_hcd
usb usb7: SerialNumber: 0000:00:1d.1
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x000018c0
usb usb8: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb8: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb8: Product: UHCI Host Controller
usb usb8: Manufacturer: Linux 2.6.37.1 uhci_hcd
usb usb8: SerialNumber: 0000:00:1d.2
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
i801_smbus 0000:00:1f.3: enabling device (0001 -> 0003)
i801_smbus 0000:00:1f.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
md: raid1 personality registered for level 1
device-mapper: ioctl: 4.18.0-ioctl (2010-06-29) initialised: dm-devel@redha=
t.com
device-mapper: dm-log-userspace: version 1.0.0 loaded
EDAC MC: Ver: 2.1.0 Feb 22 2011
EDAC MC0: Giving out device to 'i3200_edac' 'i3200': DEV 0000:00:00.0
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input=
/input2
cpuidle: using governor ladder
cpuidle: using governor menu
ioatdma: Intel(R) QuickData Technology Driver 4.00
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
GACT probability on
Mirror/redirect action on
Simple TC action Loaded
netem: version 1.2
u32 classifier
    Performance counters on
    input device check on
    Actions configured
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ctnetlink v0.93: registering with nfnetlink.
NF_TPROXY: Transparent proxy support initialized, version 4.1.0
NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
xt_time: kernel timezone is -0000
IPv4 over IPv4 tunneling driver
GRE over IPv4 demultiplexor driver
GRE over IPv4 tunneling driver
ip_tables: (C) 2000-2006 Netfilter Core Team
ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
arp_tables: (C) 2002 David S. Miller
TCP cubic registered
NET: Registered protocol family 17
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
=46reeing unused kernel memory: 452k freed
md: md0 stopped.
md: bind<sdb1>
md: bind<sda1>
bio: create slab <bio-1> at 1
md/raid1:md0: active with 2 out of 2 mirrors
md0: detected capacity change from 0 to 402915328
md0: detected capacity change from 0 to 402915328
 md0: unknown partition table
md: md1 stopped.
md: bind<sdb2>
md: bind<sda2>
md/raid1:md1: active with 2 out of 2 mirrors
md1: detected capacity change from 0 to 319667175424
md1: detected capacity change from 0 to 319667175424
 md1: unknown partition table
EXT3-fs (dm-0): recovery required on readonly filesystem
EXT3-fs (dm-0): write access will be enabled during recovery
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-0): recovery complete
EXT3-fs (dm-0): mounted filesystem with ordered data mode
udev[1111]: starting version 164
udev[1131]: renamed network interface eth1 to eth1-eth3
udev[1146]: renamed network interface eth2 to eth2-eth0
udev[1147]: renamed network interface eth3 to eth1
udev[1127]: renamed network interface eth0 to eth2
udev[1131]: renamed network interface eth1-eth3 to eth3
udev[1146]: renamed network interface eth2-eth0 to eth0
EXT3-fs (dm-0): using internal journal
Adding 1949692k swap on /dev/mapper/raid-swap.  Priority:-1 extents:1 acros=
s:1949692k=20
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-2): using internal journal
EXT3-fs (dm-2): mounted filesystem with ordered data mode
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-4): using internal journal
EXT3-fs (dm-4): mounted filesystem with ordered data mode
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-3): using internal journal
EXT3-fs (dm-3): mounted filesystem with ordered data mode
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-5): using internal journal
EXT3-fs (dm-5): mounted filesystem with ordered data mode
8021q: adding VLAN 0 to HW filter on device eth0
igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
sshd (4913): /proc/4913/oom_adj is deprecated, please use /proc/4913/oom_sc=
ore_adj instead.

--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: text/plain;
  charset="UTF-8";
  name="interrupts"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="interrupts"

           CPU0       CPU1      =20
  0:         69         12   IO-APIC-edge      timer
  1:         72         69   IO-APIC-edge      i8042
  9:          0          0   IO-APIC-fasteoi   acpi
 16:          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
 17:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 18:          0          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5=
, uhci_hcd:usb8
 22:          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
 23:          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
 88:      39270      39142   PCI-MSI-edge      ahci
 91:          0          1   PCI-MSI-edge      eth0
 92:    7478920    7496547   PCI-MSI-edge      eth0-rx-0
 93:    7416238    7419655   PCI-MSI-edge      eth0-rx-1
 94:    7380854    7374276   PCI-MSI-edge      eth0-tx-0
 95:    7165590    7151243   PCI-MSI-edge      eth0-tx-1
NMI:          0          0   Non-maskable interrupts
LOC:     513251     505430   Local timer interrupts
SPU:          0          0   Spurious interrupts
PMI:          0          0   Performance monitoring interrupts
IWI:          0          0   IRQ work interrupts
RES:      80617      84474   Rescheduling interrupts
CAL:         97        103   Function call interrupts
TLB:     117187     114836   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
MCE:          0          0   Machine check exceptions
MCP:         23         23   Machine check polls
ERR:          0
MIS:          0

--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: text/plain;
  charset="UTF-8";
  name="lspci"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="lspci"

00:00.0 Host bridge: Intel Corporation 3200/3210 Chipset DRAM Controller (rev 01)
00:01.0 PCI bridge: Intel Corporation 3200/3210 Chipset Host-Primary PCI Express Bridge (rev 01)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5 (rev 02)
00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2 (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 02)
00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 5 (rev 02)
00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 6 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
00:1f.0 ISA bridge: Intel Corporation 82801IR (ICH9R) LPC Interface Controller (rev 02)
00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 6 port SATA AHCI Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 02)
00:1f.6 Signal processing controller: Intel Corporation 82801I (ICH9 Family) Thermal Subsystem (rev 02)
01:00.0 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge A (rev 09)
01:00.1 PIC: Intel Corporation 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09)
01:00.2 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge B (rev 09)
01:00.3 PIC: Intel Corporation 6700PXH I/OxAPIC Interrupt Controller B (rev 09)
05:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) (rev 03)
0f:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
11:04.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)

--Boundary-01=_bUKtNuLEeCv9dQA
Content-Type: text/x-mpsub;
  charset="UTF-8";
  name="config-2.6.37.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="config-2.6.37.1"

#
# Automatically generated make config: don't edit
# Linux/x86_64 2.6.37.1 Kernel Configuration
# Tue Feb 22 02:16:55 2011
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_TRAMPOLINE=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
# CONFIG_KTIME_SCALAR is not set
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=y
# CONFIG_GENERIC_HARDIRQS_NO_DEPRECATED is not set
CONFIG_HAVE_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
# CONFIG_AUTO_IRQ_AFFINITY is not set
# CONFIG_IRQ_PER_CPU is not set
# CONFIG_HARDIRQS_SW_RESEND is not set
# CONFIG_SPARSE_IRQ is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
# CONFIG_CGROUPS is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EMBEDDED is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_EXTRA_PASS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_PERF_COUNTERS is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y

#
# GCOV-based kernel profiling
#
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
# CONFIG_INLINE_SPIN_UNLOCK is not set
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
# CONFIG_INLINE_READ_UNLOCK is not set
# CONFIG_INLINE_READ_UNLOCK_BH is not set
# CONFIG_INLINE_READ_UNLOCK_IRQ is not set
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
# CONFIG_INLINE_WRITE_UNLOCK is not set
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
CONFIG_MUTEX_SPIN_ON_OWNER=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
# CONFIG_AMD_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_IOMMU_API=y
CONFIG_NR_CPUS=2
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPUFreq processor drivers
#
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_POWERNOW_K8 is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_DMAR=y
# CONFIG_DMAR_DEFAULT_ON is not set
CONFIG_DMAR_FLOPPY_WA=y
# CONFIG_INTR_REMAP is not set
CONFIG_PCIEPORTBUS=y
# CONFIG_PCIEAER is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
CONFIG_PCI_IOAPIC=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_ASK_IP_FIB_HASH=y
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=y
CONFIG_IP_MULTIPLE_TABLES=y
# CONFIG_IP_ROUTE_MULTIPATH is not set
# CONFIG_IP_ROUTE_VERBOSE is not set
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IPGRE=y
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_ARPD=y
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
CONFIG_NETFILTER_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_ADDRTYPE=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_LOG=y
CONFIG_IP_NF_TARGET_ULOG=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_NF_NAT_SNMP_BASIC=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_GRE=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_NAT_AMANDA=y
CONFIG_NF_NAT_PPTP=y
CONFIG_NF_NAT_H323=y
CONFIG_NF_NAT_SIP=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_INGRESS=y

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_ROUTE=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
CONFIG_NET_ACT_SKBEDIT=y
CONFIG_NET_ACT_CSUM=y
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_RPS=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_MISC_DEVICES is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
CONFIG_MD_RAID1=y
# CONFIG_MD_RAID10 is not set
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
# CONFIG_DM_CRYPT is not set
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_MIRROR=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
# CONFIG_DM_MULTIPATH is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_IFB is not set
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_MII=y
# CONFIG_PHYLIB is not set
CONFIG_NET_ETHERNET=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_ETHOC is not set
# CONFIG_DNET is not set
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_KSZ884X_PCI is not set
# CONFIG_B44 is not set
# CONFIG_FORCEDETH is not set
CONFIG_E100=y
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R6040 is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_SC92031 is not set
# CONFIG_ATL2 is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
CONFIG_E1000=y
CONFIG_E1000E=y
# CONFIG_IP1000 is not set
CONFIG_IGB=y
CONFIG_IGB_DCA=y
# CONFIG_IGBVF is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_JME is not set
# CONFIG_STMMAC_ETH is not set
# CONFIG_PCH_GBE is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
# CONFIG_WAN is not set

#
# CAIF transport drivers
#
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
# CONFIG_DEVKMEM is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_N_GSM is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_NVRAM=y
# CONFIG_RTC is not set
# CONFIG_GEN_RTC is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_RAMOOPS is not set
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_INTEL_MID is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set

#
# PPS support
#
# CONFIG_PPS is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_BQ20Z75 is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_HWMON is not set
CONFIG_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
# CONFIG_MFD_SUPPORT is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
# CONFIG_AGP_AMD64 is not set
CONFIG_AGP_INTEL=y
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# Special HID drivers
#
# CONFIG_HID_3M_PCT is not set
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_BELKIN=y
# CONFIG_HID_CANDO is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EGALAX is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LOGITECH=y
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWII_FF is not set
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MOSART is not set
CONFIG_HID_MONTEREY=y
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_QUANTA is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_ROCCAT_KONE is not set
# CONFIG_HID_ROCCAT_PYRA is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_STANTUM is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_UAS is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_ALIX2 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_AMD64 is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
CONFIG_EDAC_I3200=y
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I7CORE is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
CONFIG_JBD2=y
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_NILFS2_FS is not set
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
CONFIG_GENERIC_ACL=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
# CONFIG_CONFIGFS_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_KERNEL is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_BKL=y
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_SYSCTL_SYSCALL_CHECK is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_INTEL_TXT is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
# CONFIG_CRYPTO_GF128MUL is not set
# CONFIG_CRYPTO_NULL is not set
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
# CONFIG_CRYPTO_ECB is not set
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA256 is not set
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
# CONFIG_CRYPTO_AES is not set
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_NLATTR=y

--Boundary-01=_bUKtNuLEeCv9dQA--

--nextPart7953574.IATS4ndeGM
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNtKUbAAoJEIHqZH0kK9IVTfwP/2HnlwJiDG3+A2jgDpGkj4YE
Ig5D7nHHdSI5VAQtyjud/9xqN7Mw7rvEaai02mH3nQGpy9+Sn9cx6W/f7tfhSx0R
SXsctlCiCDJHC5ncxHCJgYfN+DRMZhzbWELjXM0wcl+1DVXefXUr5/IaX6KALnWy
q/TLV6sBEQM47YZuQ3RjLTC0Skbo/JVHCyZ9SXhOBu8HFkwlhfdRDTbRXW6RVpcT
ISZ7NIdor1Xs9uSn5ugInucksbRAWM0inA57OkFH49nIDRvakm05NfmiE1Pb4wCu
db3E3XwUsQhQY87QNposmeZWGrlzR8iMJpdxq4NfRGF0pZn3aTqxDvlhA4kUk23J
nCgluRFwJciBGNNwYTQtqzZwVpjT2hrqBs0SNbo9lI1EmmOPDOjJKElwJKNtzvmQ
rhD0OJ0h7Hkyy3Qz33yMWzemUdM2S/ruJ32xajzf2S4HBXL7agBRDXIhsxdzPerU
a8Rp3ows5AQG62XBFLaejAAMm9LVA1v9WgOfmWzWSKYcBGiyWv9SyOm4Cd6JdC+T
iM4dkSJFltFQdv2WOIT1RqGZc7kRKholaaHAZ5uYfTGr6J/Stpp1agVSttkSzsAY
hBe/6FBQ5IcpHAGwPpglk54cD8b+71wOLaPVsc+8Qg/+uIX+BlGACJtezKKcBDI7
d8TuznxJDdFCbh+QKFhL
=glrf
-----END PGP SIGNATURE-----

--nextPart7953574.IATS4ndeGM--
