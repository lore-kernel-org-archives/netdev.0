From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm WARN() on v3.7.2
Date: Sat, 26 Jan 2013 11:53:09 +0100
Message-ID: <5103B595.8060805@broadcom.com>
References: <20130125202355.GA4846@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Pieter-Paul Giesberts" <pieterpg@broadcom.com>,
	"Hauke Mehrtens" <hauke@hauke-m.de>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2563 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776Ab3AZKxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2013 05:53:25 -0500
In-Reply-To: <20130125202355.GA4846@arwen.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2013 09:23 PM, Felipe Balbi wrote:
> Hi folks,
> 
> I'm running Fedora 18 with v3.7.2 on her MacBookAir 11" and it
> turns out that brcm is acting out, see below full dmesg. Any tips ?
> Is this fixed already ?

Thanks, Felipe

The warning itself means flush timed out, ie. not all outstanding
packets could be transmitted. It does not necessarily mean the driver
is failing. So do you have any connectivity issues after the warning
has occurred?

Arend

> cheers
> 
> [    0.000000] Initializing cgroup subsys cpuset [    0.000000]
> Initializing cgroup subsys cpu [    0.000000] Linux version
> 3.7.2-204.fc18.x86_64 (mockbuild@bkernel01.phx2.fedoraproject.org)
> (gcc version 4.7.2 20121109 (Red Hat 4.7.2-8) (GCC) ) #1 SMP Wed
> Jan 16 16:22:52 UTC 2013 [    0.000000] Command line:
> BOOT_IMAGE=/vmlinuz-3.7.2-204.fc18.x86_64
> root=/dev/mapper/fedora-root ro rd.lvm.lv=fedora/swap rd.md=0
> rd.dm=0 rd.luks=0 vconsole.keymap=us rd.lvm.lv=fedora/root rhgb
> quiet LANG=en_US.UTF-8 [    0.000000] e820: BIOS-provided physical
> RAM map: [    0.000000] BIOS-e820: [mem
> 0x0000000000000000-0x000000000008efff] usable [    0.000000]
> BIOS-e820: [mem 0x000000000008f000-0x000000000008ffff] ACPI NVS [
> 0.000000] BIOS-e820: [mem 0x0000000000090000-0x000000000009ffff]
> usable [    0.000000] BIOS-e820: [mem
> 0x0000000000100000-0x00000000aeffffff] usable [    0.000000]
> BIOS-e820: [mem 0x00000000af000000-0x00000000beffffff] reserved [
> 0.000000] BIOS-e820: [mem 0x00000000bf000000-0x00000000bf718fff]
> usable [    0.000000] BIOS-e820: [mem
> 0x00000000bf719000-0x00000000bf938fff] ACPI NVS [    0.000000]
> BIOS-e820: [mem 0x00000000bf939000-0x00000000bf953fff] usable [
> 0.000000] BIOS-e820: [mem 0x00000000bf954000-0x00000000bf96afff]
> ACPI data [    0.000000] BIOS-e820: [mem
> 0x00000000bf96b000-0x00000000bf96dfff] usable [    0.000000]
> BIOS-e820: [mem 0x00000000bf96e000-0x00000000bf99afff] reserved [
> 0.000000] BIOS-e820: [mem 0x00000000bf99b000-0x00000000bf9affff]
> usable [    0.000000] BIOS-e820: [mem
> 0x00000000bf9b0000-0x00000000bf9dafff] reserved [    0.000000]
> BIOS-e820: [mem 0x00000000bf9db000-0x00000000bfef8fff] usable [
> 0.000000] BIOS-e820: [mem 0x00000000bfef9000-0x00000000bfefffff]
> reserved [    0.000000] BIOS-e820: [mem
> 0x00000000d3200000-0x00000000d3200fff] reserved [    0.000000]
> BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved [
> 0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff]
> usable [    0.000000] e820: update [mem 0xae8df018-0xae8edc57]
> usable ==> usable [    0.000000] extended physical RAM map: [
> 0.000000] reserve setup_data: [mem
> 0x0000000000000000-0x000000000008efff] usable [    0.000000]
> reserve setup_data: [mem 0x000000000008f000-0x000000000008ffff]
> ACPI NVS [    0.000000] reserve setup_data: [mem
> 0x0000000000090000-0x000000000009ffff] usable [    0.000000]
> reserve setup_data: [mem 0x0000000000100000-0x00000000ae8df017]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000ae8df018-0x00000000ae8edc57] usable [    0.000000]
> reserve setup_data: [mem 0x00000000ae8edc58-0x00000000aeffffff]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000af000000-0x00000000beffffff] reserved [    0.000000]
> reserve setup_data: [mem 0x00000000bf000000-0x00000000bf718fff]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000bf719000-0x00000000bf938fff] ACPI NVS [    0.000000]
> reserve setup_data: [mem 0x00000000bf939000-0x00000000bf953fff]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000bf954000-0x00000000bf96afff] ACPI data [    0.000000]
> reserve setup_data: [mem 0x00000000bf96b000-0x00000000bf96dfff]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000bf96e000-0x00000000bf99afff] reserved [    0.000000]
> reserve setup_data: [mem 0x00000000bf99b000-0x00000000bf9affff]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000bf9b0000-0x00000000bf9dafff] reserved [    0.000000]
> reserve setup_data: [mem 0x00000000bf9db000-0x00000000bfef8fff]
> usable [    0.000000] reserve setup_data: [mem
> 0x00000000bfef9000-0x00000000bfefffff] reserved [    0.000000]
> reserve setup_data: [mem 0x00000000d3200000-0x00000000d3200fff]
> reserved [    0.000000] reserve setup_data: [mem
> 0x00000000ffc00000-0x00000000ffffffff] reserved [    0.000000]
> reserve setup_data: [mem 0x0000000100000000-0x000000013fffffff]
> usable [    0.000000] NX (Execute Disable) protection: active [
> 0.000000] efi: EFI v1.10 by Apple [    0.000000] efi:
> ACPI=0xbf96a000  ACPI 2.0=0xbf96a014  SMBIOS=0xbf71a000 [
> 0.000000] efi: mem00: type=7, attr=0xf,
> range=[0x0000000000000000-0x000000000008f000) (0MB) [    0.000000]
> efi: mem01: type=10, attr=0xf,
> range=[0x000000000008f000-0x0000000000090000) (0MB) [    0.000000]
> efi: mem02: type=2, attr=0xf,
> range=[0x0000000000090000-0x0000000000092000) (0MB) [    0.000000]
> efi: mem03: type=7, attr=0xf,
> range=[0x0000000000092000-0x00000000000a0000) (0MB) [    0.000000]
> efi: mem04: type=7, attr=0xf,
> range=[0x0000000000100000-0x0000000001000000) (15MB) [    0.000000]
> efi: mem05: type=2, attr=0xf,
> range=[0x0000000001000000-0x00000000023c9000) (19MB) [    0.000000]
> efi: mem06: type=7, attr=0xf,
> range=[0x00000000023c9000-0x000000003e17a000) (957MB) [
> 0.000000] efi: mem07: type=2, attr=0xf,
> range=[0x000000003e17a000-0x0000000040000000) (30MB) [    0.000000]
> efi: mem08: type=7, attr=0xf,
> range=[0x0000000040000000-0x0000000081b94000) (1051MB) [
> 0.000000] efi: mem09: type=2, attr=0xf,
> range=[0x0000000081b94000-0x00000000acf9e000) (692MB) [
> 0.000000] efi: mem10: type=7, attr=0xf,
> range=[0x00000000acf9e000-0x00000000acfa2000) (0MB) [    0.000000]
> efi: mem11: type=4, attr=0xf,
> range=[0x00000000acfa2000-0x00000000acfa6000) (0MB) [    0.000000]
> efi: mem12: type=2, attr=0xf,
> range=[0x00000000acfa6000-0x00000000ad146000) (1MB) [    0.000000]
> efi: mem13: type=4, attr=0xf,
> range=[0x00000000ad146000-0x00000000ae856000) (23MB) [    0.000000]
> efi: mem14: type=7, attr=0xf,
> range=[0x00000000ae856000-0x00000000ae8df000) (0MB) [    0.000000]
> efi: mem15: type=2, attr=0xf,
> range=[0x00000000ae8df000-0x00000000ae8ee000) (0MB) [    0.000000]
> efi: mem16: type=4, attr=0xf,
> range=[0x00000000ae8ee000-0x00000000ae96e000) (0MB) [    0.000000]
> efi: mem17: type=7, attr=0xf,
> range=[0x00000000ae96e000-0x00000000ae96f000) (0MB) [    0.000000]
> efi: mem18: type=4, attr=0xf,
> range=[0x00000000ae96f000-0x00000000af000000) (6MB) [    0.000000]
> efi: mem19: type=4, attr=0xf,
> range=[0x00000000bf000000-0x00000000bf6af000) (6MB) [    0.000000]
> efi: mem20: type=7, attr=0xf,
> range=[0x00000000bf6af000-0x00000000bf719000) (0MB) [    0.000000]
> efi: mem21: type=10, attr=0xf,
> range=[0x00000000bf719000-0x00000000bf939000) (2MB) [    0.000000]
> efi: mem22: type=7, attr=0xf,
> range=[0x00000000bf939000-0x00000000bf954000) (0MB) [    0.000000]
> efi: mem23: type=9, attr=0xf,
> range=[0x00000000bf954000-0x00000000bf96b000) (0MB) [    0.000000]
> efi: mem24: type=7, attr=0xf,
> range=[0x00000000bf96b000-0x00000000bf96e000) (0MB) [    0.000000]
> efi: mem25: type=6, attr=0x800000000000000f,
> range=[0x00000000bf96e000-0x00000000bf99b000) (0MB) [    0.000000]
> efi: mem26: type=7, attr=0xf,
> range=[0x00000000bf99b000-0x00000000bf9b0000) (0MB) [    0.000000]
> efi: mem27: type=5, attr=0x800000000000000f,
> range=[0x00000000bf9b0000-0x00000000bf9db000) (0MB) [    0.000000]
> efi: mem28: type=7, attr=0xf,
> range=[0x00000000bf9db000-0x00000000bfa64000) (0MB) [    0.000000]
> efi: mem29: type=3, attr=0xf,
> range=[0x00000000bfa64000-0x00000000bfd5f000) (2MB) [    0.000000]
> efi: mem30: type=7, attr=0xf,
> range=[0x00000000bfd5f000-0x00000000bfdb8000) (0MB) [    0.000000]
> efi: mem31: type=1, attr=0xf,
> range=[0x00000000bfdb8000-0x00000000bfeef000) (1MB) [    0.000000]
> efi: mem32: type=7, attr=0xf,
> range=[0x00000000bfeef000-0x00000000bfef9000) (0MB) [    0.000000]
> efi: mem33: type=0, attr=0xf,
> range=[0x00000000bfef9000-0x00000000bfeff000) (0MB) [    0.000000]
> efi: mem34: type=6, attr=0x800000000000000f,
> range=[0x00000000bfeff000-0x00000000bff00000) (0MB) [    0.000000]
> efi: mem35: type=7, attr=0xf,
> range=[0x0000000100000000-0x0000000140000000) (1024MB) [
> 0.000000] efi: mem36: type=0, attr=0x8000000000000000,
> range=[0x00000000af000000-0x00000000bf000000) (256MB) [
> 0.000000] efi: mem37: type=11, attr=0x8000000000000000,
> range=[0x00000000d3200000-0x00000000d3201000) (0MB) [    0.000000]
> efi: mem38: type=11, attr=0x8000000000000000,
> range=[0x00000000ffc00000-0x00000000ffc80000) (0MB) [    0.000000]
> efi: mem39: type=11, attr=0x8000000000000000,
> range=[0x00000000ffc80000-0x00000000ffca8000) (0MB) [    0.000000]
> efi: mem40: type=11, attr=0x8000000000000000,
> range=[0x00000000ffca8000-0x00000000ffcca000) (0MB) [    0.000000]
> efi: mem41: type=11, attr=0x8000000000000000,
> range=[0x00000000ffcca000-0x00000000ffffc000) (3MB) [    0.000000]
> efi: mem42: type=11, attr=0x8000000000000000,
> range=[0x00000000ffffc000-0x0000000100000000) (0MB) [    0.000000]
> DMI 2.4 present. [    0.000000] DMI: Apple Inc.
> MacBookAir3,1/Mac-942452F5819B1C1B, BIOS
> MBA31.88Z.0061.B07.1201241641 01/24/12 [    0.000000] e820: update
> [mem 0x00000000-0x0000ffff] usable ==> reserved [    0.000000]
> e820: remove [mem 0x000a0000-0x000fffff] usable [    0.000000] No
> AGP bridge found [    0.000000] e820: last_pfn = 0x140000
> max_arch_pfn = 0x400000000 [    0.000000] MTRR default type:
> write-back [    0.000000] MTRR fixed ranges enabled: [    0.000000]
> 00000-9FFFF write-back [    0.000000]   A0000-FFFFF uncachable [
> 0.000000] MTRR variable ranges enabled: [    0.000000]   0 base
> 0C0000000 mask FC0000000 uncachable [    0.000000]   1 base
> 0BFF00000 mask FFFF00000 uncachable [    0.000000]   2 disabled [
> 0.000000]   3 disabled [    0.000000]   4 disabled [    0.000000]
> 5 disabled [    0.000000]   6 disabled [    0.000000]   7 disabled 
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
> 0x7010600070106 [    0.000000] e820: last_pfn = 0xbfef9
> max_arch_pfn = 0x400000000 [    0.000000] initial memory mapped:
> [mem 0x00000000-0x1fffffff] [    0.000000] Base memory trampoline
> at [ffff880000099000] 99000 size 24576 [    0.000000]
> init_memory_mapping: [mem 0x00000000-0xbfef8fff] [    0.000000]
> [mem 0x00000000-0xbfdfffff] page 2M [    0.000000]  [mem
> 0xbfe00000-0xbfef8fff] page 4k [    0.000000] kernel direct mapping
> tables up to 0xbfef8fff @ [mem 0x1fffb000-0x1fffffff] [
> 0.000000] init_memory_mapping: [mem 0x100000000-0x13fffffff] [
> 0.000000]  [mem 0x100000000-0x13fffffff] page 2M [    0.000000]
> kernel direct mapping tables up to 0x13fffffff @ [mem
> 0xbfef7000-0xbfef8fff] [    0.000000] RAMDISK: [mem
> 0x3e17a000-0x3fffafff] [    0.000000] ACPI: RSDP 00000000bf96a014
> 00024 (v02 APPLE ) [    0.000000] ACPI: XSDT 00000000bf96a1c0 00084
> (v01 APPLE   Apple00 00000061      01000013) [    0.000000] ACPI:
> FACP 00000000bf968000 000F4 (v04 APPLE   Apple00 00000061 Loki
> 0000005F) [    0.000000] ACPI: DSDT 00000000bf95b000 0572C (v01
> APPLE  MacBookA 00030001 INTL 20061109) [    0.000000] ACPI: FACS
> 00000000bf71e000 00040 [    0.000000] ACPI: HPET 00000000bf967000
> 00038 (v01 APPLE   Apple00 00000001 Loki 0000005F) [    0.000000]
> ACPI: APIC 00000000bf966000 00068 (v01 APPLE   Apple00 00000001
> Loki 0000005F) [    0.000000] ACPI: APIC 00000000bf965000 00068
> (v02 APPLE   Apple00 00000001 Loki 0000005F) [    0.000000] ACPI:
> ASF! 00000000bf963000 000A5 (v32 APPLE   Apple00 00000001 Loki
> 0000005F) [    0.000000] ACPI: SBST 00000000bf962000 00030 (v01
> APPLE   Apple00 00000001 Loki 0000005F) [    0.000000] ACPI: ECDT
> 00000000bf961000 00053 (v01 APPLE   Apple00 00000001 Loki
> 0000005F) [    0.000000] ACPI: SSDT 00000000bf958000 00107 (v01
> APPLE  SataAhci 00001000 INTL 20061109) [    0.000000] ACPI: SSDT
> 00000000bf957000 00024 (v01 APPLE     Apple 00001000 INTL
> 20061109) [    0.000000] ACPI: SSDT 00000000bf955000 0008A (v01
> APPLE  NoSDCard 00001000 INTL 20061109) [    0.000000] ACPI: SSDT
> 00000000bf954000 004DC (v01  APPLE    CpuPm 00003000 INTL
> 20061109) [    0.000000] ACPI: MCFG 00000000bf964000 0003C (v01
> APPLE   Apple00 00000001 Loki 0000005F) [    0.000000] ACPI: BIOS
> bug: multiple APIC/MADT found, using 0 [    0.000000] ACPI: If
> "acpi_apic_instance=2" works better, notify
> linux-acpi@vger.kernel.org [    0.000000] ACPI: Local APIC address
> 0xfee00000 [    0.000000] No NUMA configuration found [
> 0.000000] Faking a node at [mem
> 0x0000000000000000-0x000000013fffffff] [    0.000000] Initmem setup
> node 0 [mem 0x00000000-0x13fffffff] [    0.000000]   NODE_DATA [mem
> 0x13ffec000-0x13fffffff] [    0.000000]
> [ffffea0000000000-ffffea0004ffffff] PMD ->
> [ffff88013b800000-ffff88013f5fffff] on node 0 [    0.000000] Zone
> ranges: [    0.000000]   DMA      [mem 0x00010000-0x00ffffff] [
> 0.000000]   DMA32    [mem 0x01000000-0xffffffff] [    0.000000]
> Normal   [mem 0x100000000-0x13fffffff] [    0.000000] Movable zone
> start for each node [    0.000000] Early memory node ranges [
> 0.000000]   node   0: [mem 0x00010000-0x0008efff] [    0.000000]
> node   0: [mem 0x00090000-0x0009ffff] [    0.000000]   node   0:
> [mem 0x00100000-0xaeffffff] [    0.000000]   node   0: [mem
> 0xbf000000-0xbf718fff] [    0.000000]   node   0: [mem
> 0xbf939000-0xbf953fff] [    0.000000]   node   0: [mem
> 0xbf96b000-0xbf96dfff] [    0.000000]   node   0: [mem
> 0xbf99b000-0xbf9affff] [    0.000000]   node   0: [mem
> 0xbf9db000-0xbfef8fff] [    0.000000]   node   0: [mem
> 0x100000000-0x13fffffff] [    0.000000] On node 0 totalpages:
> 982009 [    0.000000]   DMA zone: 64 pages used for memmap [
> 0.000000]   DMA zone: 8 pages reserved [    0.000000]   DMA zone:
> 3911 pages, LIFO batch:0 [    0.000000]   DMA32 zone: 16320 pages
> used for memmap [    0.000000]   DMA32 zone: 699562 pages, LIFO
> batch:31 [    0.000000]   Normal zone: 4096 pages used for memmap [
> 0.000000]   Normal zone: 258048 pages, LIFO batch:31 [    0.000000]
> tboot: non-0 tboot_addr but it is not of type E820_RESERVED [
> 0.000000] ACPI: PM-Timer IO Port: 0x408 [    0.000000] ACPI: Local
> APIC address 0xfee00000 [    0.000000] ACPI: LAPIC (acpi_id[0x00]
> lapic_id[0x00] enabled) [    0.000000] ACPI: LAPIC (acpi_id[0x01]
> lapic_id[0x01] enabled) [    0.000000] ACPI: LAPIC_NMI
> (acpi_id[0x00] high edge lint[0x1]) [    0.000000] ACPI: LAPIC_NMI
> (acpi_id[0x01] high edge lint[0x1]) [    0.000000] ACPI: IOAPIC
> (id[0x01] address[0xfec00000] gsi_base[0]) [    0.000000]
> IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23 [
> 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl) 
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high
> level) [    0.000000] ACPI: IRQ0 used by override. [    0.000000]
> ACPI: IRQ2 used by override. [    0.000000] ACPI: IRQ9 used by
> override. [    0.000000] Using ACPI (MADT) for SMP configuration
> information [    0.000000] ACPI: HPET id: 0x10de8201 base:
> 0xfed00000 [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs 
> [    0.000000] nr_irqs_gsi: 40 [    0.000000] PM: Registered nosave
> memory: 000000000008f000 - 0000000000090000 [    0.000000] PM:
> Registered nosave memory: 00000000000a0000 - 0000000000100000 [
> 0.000000] PM: Registered nosave memory: 00000000ae8df000 -
> 00000000ae8e0000 [    0.000000] PM: Registered nosave memory:
> 00000000ae8ed000 - 00000000ae8ee000 [    0.000000] PM: Registered
> nosave memory: 00000000af000000 - 00000000bf000000 [    0.000000]
> PM: Registered nosave memory: 00000000bf719000 - 00000000bf939000 [
> 0.000000] PM: Registered nosave memory: 00000000bf954000 -
> 00000000bf96b000 [    0.000000] PM: Registered nosave memory:
> 00000000bf96e000 - 00000000bf99b000 [    0.000000] PM: Registered
> nosave memory: 00000000bf9b0000 - 00000000bf9db000 [    0.000000]
> PM: Registered nosave memory: 00000000bfef9000 - 00000000bff00000 [
> 0.000000] PM: Registered nosave memory: 00000000bff00000 -
> 00000000d3200000 [    0.000000] PM: Registered nosave memory:
> 00000000d3200000 - 00000000d3201000 [    0.000000] PM: Registered
> nosave memory: 00000000d3201000 - 00000000ffc00000 [    0.000000]
> PM: Registered nosave memory: 00000000ffc00000 - 0000000100000000 [
> 0.000000] e820: [mem 0xd3201000-0xffbfffff] available for PCI
> devices [    0.000000] Booting paravirtualized kernel on bare
> hardware [    0.000000] setup_percpu: NR_CPUS:128
> nr_cpumask_bits:128 nr_cpu_ids:2 nr_node_ids:1 [    0.000000]
> PERCPU: Embedded 28 pages/cpu @ffff88013fc00000 s84288 r8192 d22208
> u1048576 [    0.000000] pcpu-alloc: s84288 r8192 d22208 u1048576
> alloc=1*2097152 [    0.000000] pcpu-alloc: [0] 0 1 [    0.000000]
> Built 1 zonelists in Node order, mobility grouping on.  Total
> pages: 961521 [    0.000000] Policy zone: Normal [    0.000000]
> Kernel command line: BOOT_IMAGE=/vmlinuz-3.7.2-204.fc18.x86_64
> root=/dev/mapper/fedora-root ro rd.lvm.lv=fedora/swap rd.md=0
> rd.dm=0 rd.luks=0 vconsole.keymap=us rd.lvm.lv=fedora/root rhgb
> quiet LANG=en_US.UTF-8 [    0.000000] PID hash table entries: 4096
> (order: 3, 32768 bytes) [    0.000000] __ex_table already sorted,
> skipping sort [    0.000000] xsave: enabled xstate_bv 0x3, cntxt
> size 0x240 [    0.000000] Checking aperture... [    0.000000] No
> AGP bridge found [    0.000000] Memory: 3709948k/5242880k available
> (6407k kernel code, 1314844k absent, 218088k reserved, 6793k data,
> 1068k init) [    0.000000] SLUB: Genslabs=15, HWalign=64,
> Order=0-3, MinObjects=0, CPUs=2, Nodes=1 [    0.000000]
> Hierarchical RCU implementation. [    0.000000] 	RCU restricting
> CPUs from NR_CPUS=128 to nr_cpu_ids=2. [    0.000000] NR_IRQS:8448
> nr_irqs:512 16 [    0.000000] Extended CMOS year: 2000 [
> 0.000000] Console: colour dummy device 80x25 [    0.000000] console
> [tty0] enabled [    0.000000] allocated 16252928 bytes of
> page_cgroup [    0.000000] please try 'cgroup_disable=memory'
> option if you don't want memory cgroups [    0.000000] hpet
> clockevent registered [    0.000000] tsc: Fast TSC calibration
> using PIT [    0.000000] tsc: Detected 1596.634 MHz processor [
> 0.001004] Calibrating delay loop (skipped), value calculated using
> timer frequency.. 3193.26 BogoMIPS (lpj=1596634) [    0.001009]
> pid_max: default: 32768 minimum: 301 [    0.001037]
> init_memory_mapping: [mem 0xbfeff000-0xbfefffff] [    0.001042]
> [mem 0xbfeff000-0xbfefffff] page 4k [    0.186363] Security
> Framework initialized [    0.186377] SELinux:  Initializing. [
> 0.186391] SELinux:  Starting in permissive mode [    0.187046]
> Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes) 
> [    0.189678] Inode-cache hash table entries: 262144 (order: 9,
> 2097152 bytes) [    0.190892] Mount-cache hash table entries: 256 [
> 0.191244] Initializing cgroup subsys cpuacct [    0.191248]
> Initializing cgroup subsys memory [    0.191268] Initializing
> cgroup subsys devices [    0.191270] Initializing cgroup subsys
> freezer [    0.191272] Initializing cgroup subsys net_cls [
> 0.191275] Initializing cgroup subsys blkio [    0.191277]
> Initializing cgroup subsys perf_event [    0.191321] CPU: Physical
> Processor ID: 0 [    0.191323] CPU: Processor Core ID: 0 [
> 0.191326] mce: CPU supports 6 MCE banks [    0.191337] CPU0:
> Thermal monitoring enabled (TM2) [    0.191342] process: using
> mwait in idle threads [    0.191348] Last level iTLB entries: 4KB
> 128, 2MB 4, 4MB 4 Last level dTLB entries: 4KB 256, 2MB 0, 4MB 32 
> tlb_flushall_shift: -1 [    0.191512] Freeing SMP alternatives: 24k
> freed [    0.193733] ACPI: Core revision 20120913 [    0.202451]
> ftrace: allocating 23745 entries in 93 pages [    0.213152]
> ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1 [    0.223160]
> smpboot: CPU0: Intel(R) Core(TM)2 Duo CPU     U9600  @ 1.60GHz
> (fam: 06, model: 17, stepping: 0a) [    0.224000] Performance
> Events: PEBS fmt0+, 4-deep LBR, Core2 events, Intel PMU driver. [
> 0.224000] ... version:                2 [    0.224000] ... bit
> width:              40 [    0.224000] ... generic registers:
> 2 [    0.224000] ... value mask:             000000ffffffffff [
> 0.224000] ... max period:             000000007fffffff [
> 0.224000] ... fixed-purpose events:   3 [    0.224000] ... event
> mask:             0000000700000003 [    0.225059] smpboot: Booting
> Node   0, Processors  #1 OK [    0.237029] Brought up 2 CPUs [
> 0.237036] smpboot: Total of 2 processors activated (6386.53
> BogoMIPS) [    0.237171] NMI watchdog: enabled on all CPUs,
> permanently consumes one hw-PMU counter. [    0.239080] devtmpfs:
> initialized [    0.239236] PM: Registering ACPI NVS region [mem
> 0x0008f000-0x0008ffff] (4096 bytes) [    0.239236] PM: Registering
> ACPI NVS region [mem 0xbf719000-0xbf938fff] (2228224 bytes) [
> 0.240737] atomic64 test passed for x86-64 platform with CX8 and
> with SSE [    0.240802] RTC time: 20:17:17, date: 01/25/13 [
> 0.240869] NET: Registered protocol family 16 [    0.241124] ACPI
> FADT declares the system doesn't support PCIe ASPM, so disable it [
> 0.241127] ACPI: bus type pci registered [    0.241458] PCI:
> MMCONFIG for domain 0000 [bus 00-02] at [mem 0xf0000000-0xf02fffff]
> (base 0xf0000000) [    0.241461] PCI: not using MMCONFIG [
> 0.241464] PCI: Using configuration type 1 for base access [
> 0.242707] bio: create slab <bio-0> at 0 [    0.243048] ACPI: Added
> _OSI(Module Device) [    0.243051] ACPI: Added _OSI(Processor
> Device) [    0.243053] ACPI: Added _OSI(3.0 _SCP Extensions) [
> 0.243056] ACPI: Added _OSI(Processor Aggregator Device) [
> 0.244793] ACPI: EC: EC description table is found, configuring boot
> EC [    0.249509] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query
> ignored [    0.249921] ACPI: SSDT 00000000bf71dc98 0023D (v01
> APPLE  Cpu0Ist 00003000 INTL 20061109) [    0.250313] ACPI: Dynamic
> OEM Table Load: [    0.250318] ACPI: SSDT           (null) 0023D
> (v01  APPLE  Cpu0Ist 00003000 INTL 20061109) [    0.250492] ACPI:
> SSDT 00000000bf71c618 005A6 (v01  APPLE  Cpu0Cst 00003001 INTL
> 20061109) [    0.250861] ACPI: Dynamic OEM Table Load: [
> 0.250865] ACPI: SSDT           (null) 005A6 (v01  APPLE  Cpu0Cst
> 00003001 INTL 20061109) [    0.260266] ACPI: SSDT 00000000bf71df18
> 000C8 (v01  APPLE  Cpu1Ist 00003000 INTL 20061109) [    0.260643]
> ACPI: Dynamic OEM Table Load: [    0.260647] ACPI: SSDT
> (null) 000C8 (v01  APPLE  Cpu1Ist 00003000 INTL 20061109) [
> 0.260764] ACPI: SSDT 00000000bf71bf18 00085 (v01  APPLE  Cpu1Cst
> 00003000 INTL 20061109) [    0.261139] ACPI: Dynamic OEM Table
> Load: [    0.261143] ACPI: SSDT           (null) 00085 (v01  APPLE
> Cpu1Cst 00003000 INTL 20061109) [    0.270216] ACPI: Interpreter
> enabled [    0.270221] ACPI: (supports S0 S3 S4 S5) [    0.270241]
> ACPI: Using IOAPIC for interrupt routing [    0.270262] PCI:
> MMCONFIG for domain 0000 [bus 00-02] at [mem 0xf0000000-0xf02fffff]
> (base 0xf0000000) [    0.270582] PCI: MMCONFIG at [mem
> 0xf0000000-0xf02fffff] reserved in ACPI motherboard resources [
> 0.282280] ACPI: EC: GPE = 0x57, I/O: command/status = 0x66, data =
> 0x62 [    0.282487] ACPI: No dock devices found. [    0.282492]
> PCI: Using host bridge windows from ACPI; if necessary, use
> "pci=nocrs" and report a bug [    0.282670] ACPI: PCI Root Bridge
> [PCI0] (domain 0000 [bus 00-ff]) [    0.282789] pci_root
> PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-02]
> only partially covers this bridge [    0.282828] PCI host bridge to
> bus 0000:00 [    0.282833] pci_bus 0000:00: root bus resource [bus
> 00-ff] [    0.282836] pci_bus 0000:00: root bus resource [io
> 0x0000-0x0cf7] [    0.282840] pci_bus 0000:00: root bus resource
> [io  0x0d00-0xffff] [    0.282843] pci_bus 0000:00: root bus
> resource [mem 0x000a0000-0x000bffff] [    0.282846] pci_bus
> 0000:00: root bus resource [mem 0x000c0000-0x000c3fff] [
> 0.282849] pci_bus 0000:00: root bus resource [mem
> 0x000c4000-0x000c7fff] [    0.282852] pci_bus 0000:00: root bus
> resource [mem 0x000c8000-0x000cbfff] [    0.282856] pci_bus
> 0000:00: root bus resource [mem 0x000cc000-0x000cffff] [
> 0.282859] pci_bus 0000:00: root bus resource [mem
> 0x000d0000-0x000d3fff] [    0.282862] pci_bus 0000:00: root bus
> resource [mem 0x000d4000-0x000d7fff] [    0.282865] pci_bus
> 0000:00: root bus resource [mem 0x000d8000-0x000dbfff] [
> 0.282868] pci_bus 0000:00: root bus resource [mem
> 0x000dc000-0x000dffff] [    0.282871] pci_bus 0000:00: root bus
> resource [mem 0x000e0000-0x000e3fff] [    0.282874] pci_bus
> 0000:00: root bus resource [mem 0x000e4000-0x000e7fff] [
> 0.282877] pci_bus 0000:00: root bus resource [mem
> 0x000e8000-0x000ebfff] [    0.282880] pci_bus 0000:00: root bus
> resource [mem 0x000ec000-0x000effff] [    0.282884] pci_bus
> 0000:00: root bus resource [mem 0x000f0000-0x000fffff] [
> 0.282887] pci_bus 0000:00: root bus resource [mem
> 0xc0000000-0xfebfffff] [    0.282907] pci 0000:00:00.0: [10de:0d60]
> type 00 class 0x060000 [    0.283039] pci 0000:00:00.1: [10de:0d68]
> type 00 class 0x050000 [    0.283225] pci 0000:00:01.0: [10de:0d6d]
> type 00 class 0x050000 [    0.283403] pci 0000:00:01.1: [10de:0d6e]
> type 00 class 0x050000 [    0.283581] pci 0000:00:01.2: [10de:0d6f]
> type 00 class 0x050000 [    0.283759] pci 0000:00:01.3: [10de:0d70]
> type 00 class 0x050000 [    0.283942] pci 0000:00:02.0: [10de:0d71]
> type 00 class 0x050000 [    0.284127] pci 0000:00:02.1: [10de:0d72]
> type 00 class 0x050000 [    0.284306] pci 0000:00:03.0: [10de:0d80]
> type 00 class 0x060100 [    0.284319] pci 0000:00:03.0: reg 10: [io
> 0x2100-0x21ff] [    0.284377] pci 0000:00:03.1: [10de:0d7b] type 00
> class 0x050000 [    0.284475] pci 0000:00:03.2: [10de:0d79] type 00
> class 0x0c0500 [    0.284493] pci 0000:00:03.2: reg 10: [io
> 0x2000-0x20ff] [    0.284503] pci 0000:00:03.2: reg 14: [mem
> 0xd3286000-0xd3287fff] [    0.284525] pci 0000:00:03.2: reg 20: [io
> 0x2240-0x227f] [    0.284534] pci 0000:00:03.2: reg 24: [io
> 0x2200-0x223f] [    0.284576] pci 0000:00:03.2: PME# supported from
> D3hot D3cold [    0.284607] pci 0000:00:03.3: [10de:0d69] type 00
> class 0x050000 [    0.284826] pci 0000:00:03.4: [10de:0d7a] type 00
> class 0x0b4000 [    0.284850] pci 0000:00:03.4: reg 10: [mem
> 0xd3200000-0xd327ffff] [    0.285009] pci 0000:00:04.0: [10de:0d9c]
> type 00 class 0x0c0310 [    0.285025] pci 0000:00:04.0: reg 10:
> [mem 0xd328a000-0xd328afff] [    0.285087] pci 0000:00:04.0:
> supports D1 D2 [    0.285090] pci 0000:00:04.0: PME# supported from
> D0 D1 D2 D3hot D3cold [    0.285111] pci 0000:00:04.1: [10de:0d9d]
> type 00 class 0x0c0320 [    0.285129] pci 0000:00:04.1: reg 10:
> [mem 0xd328b100-0xd328b1ff] [    0.285201] pci 0000:00:04.1:
> supports D1 D2 [    0.285204] pci 0000:00:04.1: PME# supported from
> D0 D1 D2 D3hot D3cold [    0.285238] pci 0000:00:06.0: [10de:0d9c]
> type 00 class 0x0c0310 [    0.285253] pci 0000:00:06.0: reg 10:
> [mem 0xd3289000-0xd3289fff] [    0.285315] pci 0000:00:06.0:
> supports D1 D2 [    0.285318] pci 0000:00:06.0: PME# supported from
> D0 D1 D2 D3hot D3cold [    0.285339] pci 0000:00:06.1: [10de:0d9d]
> type 00 class 0x0c0320 [    0.285356] pci 0000:00:06.1: reg 10:
> [mem 0xd328b000-0xd328b0ff] [    0.285429] pci 0000:00:06.1:
> supports D1 D2 [    0.285432] pci 0000:00:06.1: PME# supported from
> D0 D1 D2 D3hot D3cold [    0.285467] pci 0000:00:08.0: [10de:0d94]
> type 00 class 0x040300 [    0.285485] pci 0000:00:08.0: reg 10:
> [mem 0xd3280000-0xd3283fff] [    0.285560] pci 0000:00:08.0: PME#
> supported from D3hot D3cold [    0.285586] pci 0000:00:0a.0:
> [10de:0d88] type 00 class 0x010601 [    0.285602] pci 0000:00:0a.0:
> reg 10: [io  0x2298-0x229f] [    0.285611] pci 0000:00:0a.0: reg
> 14: [io  0x22a4-0x22a7] [    0.285619] pci 0000:00:0a.0: reg 18:
> [io  0x2290-0x2297] [    0.285628] pci 0000:00:0a.0: reg 1c: [io
> 0x22a0-0x22a3] [    0.285636] pci 0000:00:0a.0: reg 20: [io
> 0x2280-0x228f] [    0.285645] pci 0000:00:0a.0: reg 24: [mem
> 0xd3284000-0xd3285fff] [    0.285702] pci 0000:00:0b.0: [10de:0d75]
> type 00 class 0x050000 [    0.285720] pci 0000:00:0b.0: reg 10:
> [mem 0xd3288000-0xd3288fff] [    0.285868] pci 0000:00:15.0:
> [10de:0d9b] type 01 class 0x060400 [    0.286149] pci 0000:00:15.0:
> PME# supported from D0 D1 D2 D3hot D3cold [    0.286217] pci
> 0000:00:17.0: [10de:0d76] type 01 class 0x060400 [    0.286273] pci
> 0000:00:17.0: PME# supported from D0 D3hot D3cold [    0.286550]
> pci 0000:01:00.0: [14e4:4353] type 00 class 0x028000 [    0.286574]
> pci 0000:01:00.0: reg 10: [mem 0xd3100000-0xd3103fff 64bit] [
> 0.286693] pci 0000:01:00.0: supports D1 D2 [    0.286696] pci
> 0000:01:00.0: PME# supported from D0 D3hot D3cold [    0.286764]
> pci 0000:00:15.0: PCI bridge to [bus 01] [    0.286789] pci
> 0000:00:15.0:   bridge window [mem 0xd3100000-0xd31fffff] [
> 0.286849] pci 0000:02:00.0: [10de:08a2] type 00 class 0x030000 [
> 0.286866] pci 0000:02:00.0: reg 10: [mem 0xd2000000-0xd2ffffff] [
> 0.286878] pci 0000:02:00.0: reg 14: [mem 0xc0000000-0xcfffffff
> 64bit pref] [    0.286889] pci 0000:02:00.0: reg 1c: [mem
> 0xd0000000-0xd1ffffff 64bit pref] [    0.286898] pci 0000:02:00.0:
> reg 24: [io  0x1000-0x107f] [    0.286907] pci 0000:02:00.0: reg
> 30: [mem 0xd3000000-0xd301ffff pref] [    0.286971] pci
> 0000:00:17.0: PCI bridge to [bus 02] [    0.286977] pci
> 0000:00:17.0:   bridge window [io  0x1000-0x1fff] [    0.286981]
> pci 0000:00:17.0:   bridge window [mem 0xd2000000-0xd30fffff] [
> 0.286987] pci 0000:00:17.0:   bridge window [mem
> 0xc0000000-0xd1ffffff 64bit pref] [    0.287014] ACPI: PCI
> Interrupt Routing Table [\_SB_.PCI0._PRT] [    0.287201] ACPI: PCI
> Interrupt Routing Table [\_SB_.PCI0.IXVE._PRT] [    0.287336]
> pci0000:00: Requesting ACPI _OSC control (0x1d) [    0.287525]
> pci0000:00: ACPI _OSC control (0x1d) granted [    0.303734] ACPI:
> PCI Interrupt Link [LNK1] (IRQs *16 17 18 19 20 21 22 23) [
> 0.303850] ACPI: PCI Interrupt Link [LNK2] (IRQs 16 *17 18 19 20 21
> 22 23) [    0.303958] ACPI: PCI Interrupt Link [LNK3] (IRQs 16 17
> *18 19 20 21 22 23) [    0.304073] ACPI: PCI Interrupt Link [LNK4]
> (IRQs 16 17 18 *19 20 21 22 23) [    0.304180] ACPI: PCI Interrupt
> Link [Z00J] (IRQs 16 17 18 19 20 *21 22 23) [    0.304288] ACPI:
> PCI Interrupt Link [Z00K] (IRQs 16 17 18 19 20 *21 22 23) [
> 0.304395] ACPI: PCI Interrupt Link [Z00L] (IRQs 16 17 18 19 20 *21
> 22 23) [    0.304503] ACPI: PCI Interrupt Link [Z00M] (IRQs 16 17
> 18 19 20 *21 22 23) [    0.304610] ACPI: PCI Interrupt Link [LSMB]
> (IRQs 16 17 18 19 20 21 *22 23) [    0.304716] ACPI: PCI Interrupt
> Link [LUS0] (IRQs 16 *17 18 19 20 21 22 23) [    0.304822] ACPI:
> PCI Interrupt Link [LUS2] (IRQs 16 *17 18 19 20 21 22 23) [
> 0.304928] ACPI: PCI Interrupt Link [LMAC] (IRQs 16 *17 18 19 20 21
> 22 23) [    0.305044] ACPI: PCI Interrupt Link [LAZA] (IRQs 16 17
> 18 19 *20 21 22 23) [    0.305153] ACPI: PCI Interrupt Link [LGPU]
> (IRQs *16 17 18 19 20 21 22 23) [    0.305256] ACPI: PCI Interrupt
> Link [LPID] (IRQs 16 17 18 19 20 21 22 23) *0, disabled. [
> 0.305364] ACPI: PCI Interrupt Link [LSI0] (IRQs 16 17 *18 19 20 21
> 22 23) [    0.305470] ACPI: PCI Interrupt Link [Z000] (IRQs 16 17
> *18 19 20 21 22 23) [    0.305576] ACPI: PCI Interrupt Link [Z001]
> (IRQs 16 17 18 19 20 21 *22 23) [    0.305679] ACPI: PCI Interrupt
> Link [LPMU] (IRQs 16 17 18 19 20 21 22 23) *0, disabled. [
> 0.305767] vgaarb: device added:
> PCI:0000:02:00.0,decodes=io+mem,owns=none,locks=none [    0.305767]
> vgaarb: loaded [    0.305767] vgaarb: bridge control possible
> 0000:02:00.0 [    0.305767] SCSI subsystem initialized [
> 0.305767] ACPI: bus type scsi registered [    0.305767] libata
> version 3.00 loaded. [    0.305767] ACPI: bus type usb registered [
> 0.305767] usbcore: registered new interface driver usbfs [
> 0.305767] usbcore: registered new interface driver hub [
> 0.306015] usbcore: registered new device driver usb [    0.306060]
> PCI: Using ACPI for IRQ routing [    0.306060] PCI:
> pci_cache_line_size set to 64 bytes [    0.306096] e820: reserve
> RAM buffer [mem 0x0008f000-0x0008ffff] [    0.306099] e820: reserve
> RAM buffer [mem 0xae8df018-0xafffffff] [    0.306102] e820: reserve
> RAM buffer [mem 0xaf000000-0xafffffff] [    0.306104] e820: reserve
> RAM buffer [mem 0xbf719000-0xbfffffff] [    0.306107] e820: reserve
> RAM buffer [mem 0xbf954000-0xbfffffff] [    0.306111] e820: reserve
> RAM buffer [mem 0xbf96e000-0xbfffffff] [    0.306113] e820: reserve
> RAM buffer [mem 0xbf9b0000-0xbfffffff] [    0.306116] e820: reserve
> RAM buffer [mem 0xbfef9000-0xbfffffff] [    0.306243] NetLabel:
> Initializing [    0.306246] NetLabel:  domain hash size = 128 [
> 0.306247] NetLabel:  protocols = UNLABELED CIPSOv4 [    0.306263]
> NetLabel:  unlabeled traffic allowed by default [    0.306334]
> HPET: 4 timers in total, 0 timers will be used for per-cpu timer [
> 0.306341] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31, 31 [
> 0.306348] hpet0: 4 comparators, 64-bit 25.000000 MHz counter [
> 0.308013] Switching to clocksource hpet [    0.317929] pnp: PnP
> ACPI init [    0.317959] ACPI: bus type pnp registered [
> 0.318116] pnp 00:00: [bus 00-ff] [    0.318121] pnp 00:00: [io
> 0x0cf8-0x0cff] [    0.318125] pnp 00:00: [io  0x0000-0x0cf7
> window] [    0.318128] pnp 00:00: [io  0x0d00-0xffff window] [
> 0.318131] pnp 00:00: [mem 0x000a0000-0x000bffff window] [
> 0.318135] pnp 00:00: [mem 0x000c0000-0x000c3fff window] [
> 0.318138] pnp 00:00: [mem 0x000c4000-0x000c7fff window] [
> 0.318141] pnp 00:00: [mem 0x000c8000-0x000cbfff window] [
> 0.318144] pnp 00:00: [mem 0x000cc000-0x000cffff window] [
> 0.318147] pnp 00:00: [mem 0x000d0000-0x000d3fff window] [
> 0.318154] pnp 00:00: [mem 0x000d4000-0x000d7fff window] [
> 0.318158] pnp 00:00: [mem 0x000d8000-0x000dbfff window] [
> 0.318161] pnp 00:00: [mem 0x000dc000-0x000dffff window] [
> 0.318164] pnp 00:00: [mem 0x000e0000-0x000e3fff window] [
> 0.318167] pnp 00:00: [mem 0x000e4000-0x000e7fff window] [
> 0.318170] pnp 00:00: [mem 0x000e8000-0x000ebfff window] [
> 0.318173] pnp 00:00: [mem 0x000ec000-0x000effff window] [
> 0.318176] pnp 00:00: [mem 0x000f0000-0x000fffff window] [
> 0.318180] pnp 00:00: [mem 0xc0000000-0xfebfffff window] [
> 0.318239] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03
> (active) [    0.318266] pnp 00:01: [mem
> 0x00000000-0xffffffffffffffff disabled] [    0.318269] pnp 00:01:
> [mem 0xf0000000-0xf3ffffff] [    0.318341] system 00:01: [mem
> 0xf0000000-0xf3ffffff] has been reserved [    0.318347] system
> 00:01: Plug and Play ACPI device, IDs PNP0c02 (active) [
> 0.318364] pnp 00:02: [io  0x0300-0x031f] [    0.318382] pnp 00:02:
> [irq 6] [    0.318407] pnp 00:02: Plug and Play ACPI device, IDs
> APP0001 (active) [    0.318465] pnp 00:03: [io  0x0000-0x0008] [
> 0.318468] pnp 00:03: [io  0x000a-0x000f] [    0.318471] pnp 00:03:
> [io  0x0081-0x0083] [    0.318474] pnp 00:03: [io  0x0087] [
> 0.318477] pnp 00:03: [io  0x0089-0x008b] [    0.318480] pnp 00:03:
> [io  0x008f] [    0.318483] pnp 00:03: [io  0x00c0-0x00d1] [
> 0.318486] pnp 00:03: [io  0x00d4-0x00df] [    0.318489] pnp 00:03:
> [dma 4] [    0.318520] pnp 00:03: Plug and Play ACPI device, IDs
> PNP0200 (active) [    0.318593] pnp 00:04: [irq 0 disabled] [
> 0.318602] pnp 00:04: [irq 8] [    0.318605] pnp 00:04: [mem
> 0xfed00000-0xfed003ff] [    0.318647] system 00:04: [mem
> 0xfed00000-0xfed003ff] has been reserved [    0.318652] system
> 00:04: Plug and Play ACPI device, IDs PNP0103 PNP0c01 (active) [
> 0.318667] pnp 00:05: [io  0x00f0-0x00f1] [    0.318674] pnp 00:05:
> [irq 13] [    0.318709] pnp 00:05: Plug and Play ACPI device, IDs
> PNP0c04 (active) [    0.318853] pnp 00:06: [io  0x0400-0x047f] [
> 0.318857] pnp 00:06: [io  0x0480-0x04ff] [    0.318860] pnp 00:06:
> [io  0x0500-0x057f] [    0.318863] pnp 00:06: [io  0x0580-0x05ff] [
> 0.318866] pnp 00:06: [io  0x0800-0x087f] [    0.318869] pnp 00:06:
> [io  0x0880-0x08ff] [    0.318871] pnp 00:06: [io  0x0010-0x001f] [
> 0.318874] pnp 00:06: [io  0x0022-0x003f] [    0.318877] pnp 00:06:
> [io  0x0044-0x005f] [    0.318880] pnp 00:06: [io  0x0063] [
> 0.318883] pnp 00:06: [io  0x0065] [    0.318886] pnp 00:06: [io
> 0x0067-0x006f] [    0.318889] pnp 00:06: [io  0x0072-0x0073] [
> 0.318892] pnp 00:06: [io  0x0074-0x007f] [    0.318895] pnp 00:06:
> [io  0x0091-0x0093] [    0.318901] pnp 00:06: [io  0x0097-0x009f] [
> 0.318904] pnp 00:06: [io  0x00a2-0x00bf] [    0.318907] pnp 00:06:
> [io  0x00e0-0x00ef] [    0.318910] pnp 00:06: [io  0x04d0-0x04d1] [
> 0.318913] pnp 00:06: [io  0x0080] [    0.318916] pnp 00:06: [io
> 0x0295-0x0296] [    0.318970] system 00:06: [io  0x0400-0x047f] has
> been reserved [    0.318974] system 00:06: [io  0x0480-0x04ff] has
> been reserved [    0.318977] system 00:06: [io  0x0500-0x057f] has
> been reserved [    0.318981] system 00:06: [io  0x0580-0x05ff] has
> been reserved [    0.318984] system 00:06: [io  0x0800-0x087f] has
> been reserved [    0.318988] system 00:06: [io  0x0880-0x08ff] has
> been reserved [    0.318992] system 00:06: [io  0x04d0-0x04d1] has
> been reserved [    0.318996] system 00:06: [io  0x0295-0x0296] has
> been reserved [    0.319011] system 00:06: Plug and Play ACPI
> device, IDs PNP0c02 (active) [    0.319023] pnp 00:07: [io
> 0x0070-0x0077] [    0.319055] pnp 00:07: Plug and Play ACPI device,
> IDs PNP0b00 (active) [    0.324425] pnp: PnP ACPI: found 8 devices 
> [    0.324428] ACPI: ACPI bus type pnp unregistered [    0.332048]
> pci 0000:00:15.0: PCI bridge to [bus 01] [    0.332064] pci
> 0000:00:15.0:   bridge window [mem 0xd3100000-0xd31fffff] [
> 0.332088] pci 0000:00:17.0: PCI bridge to [bus 02] [    0.332091]
> pci 0000:00:17.0:   bridge window [io  0x1000-0x1fff] [
> 0.332097] pci 0000:00:17.0:   bridge window [mem
> 0xd2000000-0xd30fffff] [    0.332102] pci 0000:00:17.0:   bridge
> window [mem 0xc0000000-0xd1ffffff 64bit pref] [    0.332291] ACPI:
> PCI Interrupt Link [Z00J] enabled at IRQ 21 [    0.332312] pci
> 0000:00:17.0: setting latency timer to 64 [    0.332318] pci_bus
> 0000:00: resource 4 [io  0x0000-0x0cf7] [    0.332321] pci_bus
> 0000:00: resource 5 [io  0x0d00-0xffff] [    0.332324] pci_bus
> 0000:00: resource 6 [mem 0x000a0000-0x000bffff] [    0.332328]
> pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000c3fff] [
> 0.332331] pci_bus 0000:00: resource 8 [mem 0x000c4000-0x000c7fff] [
> 0.332334] pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000cbfff] [
> 0.332337] pci_bus 0000:00: resource 10 [mem 0x000cc000-0x000cffff] 
> [    0.332340] pci_bus 0000:00: resource 11 [mem
> 0x000d0000-0x000d3fff] [    0.332343] pci_bus 0000:00: resource 12
> [mem 0x000d4000-0x000d7fff] [    0.332346] pci_bus 0000:00:
> resource 13 [mem 0x000d8000-0x000dbfff] [    0.332349] pci_bus
> 0000:00: resource 14 [mem 0x000dc000-0x000dffff] [    0.332352]
> pci_bus 0000:00: resource 15 [mem 0x000e0000-0x000e3fff] [
> 0.332355] pci_bus 0000:00: resource 16 [mem 0x000e4000-0x000e7fff] 
> [    0.332358] pci_bus 0000:00: resource 17 [mem
> 0x000e8000-0x000ebfff] [    0.332361] pci_bus 0000:00: resource 18
> [mem 0x000ec000-0x000effff] [    0.332365] pci_bus 0000:00:
> resource 19 [mem 0x000f0000-0x000fffff] [    0.332368] pci_bus
> 0000:00: resource 20 [mem 0xc0000000-0xfebfffff] [    0.332372]
> pci_bus 0000:01: resource 1 [mem 0xd3100000-0xd31fffff] [
> 0.332375] pci_bus 0000:02: resource 0 [io  0x1000-0x1fff] [
> 0.332378] pci_bus 0000:02: resource 1 [mem 0xd2000000-0xd30fffff] [
> 0.332382] pci_bus 0000:02: resource 2 [mem 0xc0000000-0xd1ffffff
> 64bit pref] [    0.332438] NET: Registered protocol family 2 [
> 0.333708] TCP established hash table entries: 524288 (order: 11,
> 8388608 bytes) [    0.338299] TCP bind hash table entries: 65536
> (order: 8, 1048576 bytes) [    0.338901] TCP: Hash tables
> configured (established 524288 bind 65536) [    0.338991] TCP: reno
> registered [    0.339034] UDP hash table entries: 2048 (order: 4,
> 65536 bytes) [    0.339082] UDP-Lite hash table entries: 2048
> (order: 4, 65536 bytes) [    0.339247] NET: Registered protocol
> family 1 [    0.339587] ACPI: PCI Interrupt Link [LUS0] enabled at
> IRQ 17 [    0.390205] ACPI: PCI Interrupt Link [LUS2] enabled at
> IRQ 23 [    0.390407] ACPI: PCI Interrupt Link [Z000] enabled at
> IRQ 18 [    0.441195] ACPI: PCI Interrupt Link [Z001] enabled at
> IRQ 22 [    0.441335] PCI: CLS 256 bytes, default 64 [    0.441411]
> Unpacking initramfs... [    1.302075] Freeing initrd memory: 31236k
> freed [    1.320056] PCI-DMA: Using software bounce buffering for
> IO (SWIOTLB) [    1.320065] software IO TLB [mem
> 0xa8fa2000-0xacfa1fff] (64MB) mapped at
> [ffff8800a8fa2000-ffff8800acfa1fff] [    1.320866] Initialise
> module verification [    1.320932] audit: initializing netlink
> socket (disabled) [    1.320952] type=2000 audit(1359145038.320:1):
> initialized [    1.355228] HugeTLB registered 2 MB page size,
> pre-allocated 0 pages [    1.357586] VFS: Disk quotas dquot_6.5.2 [
> 1.357651] Dquot-cache hash table entries: 512 (order 0, 4096
> bytes) [    1.358271] msgmni has been set to 7386 [    1.358362]
> SELinux:  Registering netfilter hooks [    1.359033] alg: No test
> for stdrng (krng) [    1.359043] NET: Registered protocol family
> 38 [    1.359048] Key type asymmetric registered [    1.359050]
> Asymmetric key parser 'x509' registered [    1.359104] Block layer
> SCSI generic (bsg) driver version 0.4 loaded (major 252) [
> 1.359140] io scheduler noop registered [    1.359143] io scheduler
> deadline registered [    1.359154] io scheduler cfq registered
> (default) [    1.359471] pcieport 0000:00:15.0: irq 40 for
> MSI/MSI-X [    1.359701] pcieport 0000:00:15.0: Signaling PME
> through PCIe PME interrupt [    1.359705] pci 0000:01:00.0:
> Signaling PME through PCIe PME interrupt [    1.359715] pcie_pme
> 0000:00:15.0:pcie01: service driver pcie_pme loaded [    1.359735]
> pci_hotplug: PCI Hot Plug PCI Core version: 0.5 [    1.359759]
> pciehp: PCI Express Hot Plug Controller Driver version: 0.4 [
> 1.359762] acpiphp: ACPI Hot Plug PCI Controller Driver version:
> 0.5 [    1.360257] efifb: probing for efifb [    1.361812] efifb:
> framebuffer at 0xc0010000, mapped to 0xffffc90001780000, using
> 6144k, total 6144k [    1.361815] efifb: mode is 1366x768x32,
> linelength=8192, pages=1 [    1.361817] efifb: scrolling: redraw [
> 1.361820] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0 [
> 1.361922] Console: switching to colour frame buffer device 170x48 [
> 1.366152] fb0: EFI VGA frame buffer device [    1.366160]
> intel_idle: does not run on family 6 model 23 [    1.366244] ACPI:
> AC Adapter [ADP1] (on-line) [    1.366365] input: Lid Switch as
> /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input0 [
> 1.366386] ACPI: Lid Switch [LID0] [    1.366438] input: Power
> Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input1 
> [    1.366443] ACPI: Power Button [PWRB] [    1.366492] input:
> Sleep Button as
> /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input2 [
> 1.366496] ACPI: Sleep Button [SLPB] [    1.366568] input: Power
> Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3 [
> 1.366571] ACPI: Power Button [PWRF] [    1.366803] ACPI: Requesting
> acpi_cpufreq [    1.368343] Monitor-Mwait will be used to enter C-1
> state [    1.368352] Monitor-Mwait will be used to enter C-2 state 
> [    1.368356] Monitor-Mwait will be used to enter C-3 state [
> 1.368361] tsc: Marking TSC unstable due to TSC halts in idle [
> 1.368374] ACPI: acpi_idle registered with cpuidle [    1.381106]
> GHES: HEST is not enabled! [    1.381201] Serial: 8250/16550
> driver, 4 ports, IRQ sharing enabled [    1.381991] Non-volatile
> memory driver v1.3 [    1.381994] Linux agpgart interface v0.103 [
> 1.383652] loop: module loaded [    1.383736] ahci 0000:00:0a.0:
> version 3.0 [    1.384173] ACPI: PCI Interrupt Link [LSI0] enabled
> at IRQ 20 [    1.384331] ahci 0000:00:0a.0: irq 41 for MSI/MSI-X [
> 1.384371] ahci 0000:00:0a.0: AHCI 0001.0300 32 slots 1 ports 3 Gbps
> 0x1 impl SATA mode [    1.384377] ahci 0000:00:0a.0: flags: 64bit
> ncq sntf pm led pio slum part apst [    1.384382] ahci
> 0000:00:0a.0: setting latency timer to 64 [    1.384714] scsi0 :
> ahci [    1.384788] ata1: SATA max UDMA/133 abar m8192@0xd3284000
> port 0xd3284100 irq 41 [    1.384906] libphy: Fixed MDIO Bus:
> probed [    1.384972] ehci_hcd: USB 2.0 'Enhanced' Host Controller
> (EHCI) Driver [    1.385026] ehci_hcd 0000:00:04.1: setting latency
> timer to 64 [    1.385031] ehci_hcd 0000:00:04.1: EHCI Host
> Controller [    1.385149] ehci_hcd 0000:00:04.1: new USB bus
> registered, assigned bus number 1 [    1.385162] ehci_hcd
> 0000:00:04.1: debug port 1 [    1.385187] ehci_hcd 0000:00:04.1:
> disable lpm/ppcd for nvidia mcp89 [    1.406027] ehci_hcd
> 0000:00:04.1: cache line size of 256 is not supported [
> 1.406047] ehci_hcd 0000:00:04.1: irq 23, io mem 0xd328b100 [
> 1.412025] ehci_hcd 0000:00:04.1: USB 2.0 started, EHCI 1.10 [
> 1.412053] usb usb1: New USB device found, idVendor=1d6b,
> idProduct=0002 [    1.412057] usb usb1: New USB device strings:
> Mfr=3, Product=2, SerialNumber=1 [    1.412060] usb usb1: Product:
> EHCI Host Controller [    1.412063] usb usb1: Manufacturer: Linux
> 3.7.2-204.fc18.x86_64 ehci_hcd [    1.412066] usb usb1:
> SerialNumber: 0000:00:04.1 [    1.412210] hub 1-0:1.0: USB hub
> found [    1.412216] hub 1-0:1.0: 6 ports detected [    1.412753]
> ehci_hcd 0000:00:06.1: setting latency timer to 64 [    1.412758]
> ehci_hcd 0000:00:06.1: EHCI Host Controller [    1.412815] ehci_hcd
> 0000:00:06.1: new USB bus registered, assigned bus number 2 [
> 1.412826] ehci_hcd 0000:00:06.1: debug port 1 [    1.412846]
> ehci_hcd 0000:00:06.1: disable lpm/ppcd for nvidia mcp89 [
> 1.433025] ehci_hcd 0000:00:06.1: cache line size of 256 is not
> supported [    1.433043] ehci_hcd 0000:00:06.1: irq 22, io mem
> 0xd328b000 [    1.439024] ehci_hcd 0000:00:06.1: USB 2.0 started,
> EHCI 1.10 [    1.439043] usb usb2: New USB device found,
> idVendor=1d6b, idProduct=0002 [    1.439046] usb usb2: New USB
> device strings: Mfr=3, Product=2, SerialNumber=1 [    1.439050] usb
> usb2: Product: EHCI Host Controller [    1.439053] usb usb2:
> Manufacturer: Linux 3.7.2-204.fc18.x86_64 ehci_hcd [    1.439056]
> usb usb2: SerialNumber: 0000:00:06.1 [    1.439187] hub 2-0:1.0:
> USB hub found [    1.439193] hub 2-0:1.0: 6 ports detected [
> 1.439718] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver [
> 1.439747] ohci_hcd 0000:00:04.0: setting latency timer to 64 [
> 1.439752] ohci_hcd 0000:00:04.0: OHCI Host Controller [
> 1.439838] ohci_hcd 0000:00:04.0: new USB bus registered, assigned
> bus number 3 [    1.439867] ohci_hcd 0000:00:04.0: irq 17, io mem
> 0xd328a000 [    1.482970] ACPI: Battery Slot [BAT0] (battery
> present) [    1.492037] usb usb3: New USB device found,
> idVendor=1d6b, idProduct=0001 [    1.492041] usb usb3: New USB
> device strings: Mfr=3, Product=2, SerialNumber=1 [    1.492044] usb
> usb3: Product: OHCI Host Controller [    1.492048] usb usb3:
> Manufacturer: Linux 3.7.2-204.fc18.x86_64 ohci_hcd [    1.492051]
> usb usb3: SerialNumber: 0000:00:04.0 [    1.492184] hub 3-0:1.0:
> USB hub found [    1.492191] hub 3-0:1.0: 6 ports detected [
> 1.492729] ohci_hcd 0000:00:06.0: setting latency timer to 64 [
> 1.492733] ohci_hcd 0000:00:06.0: OHCI Host Controller [
> 1.492785] ohci_hcd 0000:00:06.0: new USB bus registered, assigned
> bus number 4 [    1.492810] ohci_hcd 0000:00:06.0: irq 18, io mem
> 0xd3289000 [    1.545038] usb usb4: New USB device found,
> idVendor=1d6b, idProduct=0001 [    1.545042] usb usb4: New USB
> device strings: Mfr=3, Product=2, SerialNumber=1 [    1.545045] usb
> usb4: Product: OHCI Host Controller [    1.545049] usb usb4:
> Manufacturer: Linux 3.7.2-204.fc18.x86_64 ohci_hcd [    1.545052]
> usb usb4: SerialNumber: 0000:00:06.0 [    1.545182] hub 4-0:1.0:
> USB hub found [    1.545189] hub 4-0:1.0: 6 ports detected [
> 1.545700] uhci_hcd: USB Universal Host Controller Interface driver 
> [    1.545779] usbcore: registered new interface driver usbserial [
> 1.545790] usbcore: registered new interface driver
> usbserial_generic [    1.545799] usbserial: USB Serial support
> registered for generic [    1.545856] mousedev: PS/2 mouse device
> common for all mice [    1.546127] rtc_cmos 00:07: RTC can wake
> from S4 [    1.546395] rtc_cmos 00:07: rtc core: registered
> rtc_cmos as rtc0 [    1.546448] rtc0: alarms up to one year, y3k,
> 242 bytes nvram, hpet irqs [    1.546577] device-mapper: uevent:
> version 1.0.3 [    1.546671] device-mapper: ioctl: 4.23.0-ioctl
> (2012-07-25) initialised: dm-devel@redhat.com [    1.546811]
> cpuidle: using governor ladder [    1.546874] cpuidle: using
> governor menu [    1.547245] EFI Variables Facility v0.08
> 2004-May-17 [    1.689245] ata1: SATA link up 3.0 Gbps (SStatus 123
> SControl 300) [    1.689573] ata1.00: ACPI cmd ef/10:03:00:00:00:a0
> (SET FEATURES) filtered out [    1.689661] ata1.00: ATA-8: APPLE
> SSD TS128C, CJAA0201, max UDMA/100 [    1.689665] ata1.00:
> 236978176 sectors, multi 16: LBA48 [    1.690034] ata1.00: ACPI cmd
> ef/10:03:00:00:00:a0 (SET FEATURES) filtered out [    1.690133]
> ata1.00: configured for UDMA/100 [    1.690268] scsi 0:0:0:0:
> Direct-Access     ATA      APPLE SSD TS128C CJAA PQ: 0 ANSI: 5 [
> 1.690456] sd 0:0:0:0: Attached scsi generic sg0 type 0 [
> 1.690527] ACPI: Invalid Power Resource to register! [    1.690563]
> sd 0:0:0:0: [sda] 236978176 512-byte logical blocks: (121 GB/113
> GiB) [    1.690646] sd 0:0:0:0: [sda] Write Protect is off [
> 1.690650] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00 [    1.690677]
> sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,
> doesn't support DPO or FUA [    1.692724]  sda: sda1 sda2 sda3 [
> 1.693088] sd 0:0:0:0: [sda] Attached SCSI disk [    1.822881]
> usbcore: registered new interface driver usbhid [    1.822883]
> usbhid: USB HID core driver [    1.822914] drop_monitor:
> Initializing network drop monitor service [    1.823034] ip_tables:
> (C) 2000-2006 Netfilter Core Team [    1.823081] TCP: cubic
> registered [    1.823084] Initializing XFRM netlink socket [
> 1.823239] NET: Registered protocol family 10 [    1.823461] mip6:
> Mobile IPv6 [    1.823465] NET: Registered protocol family 17 [
> 1.823861] PM: Hibernation image not present or could not be
> loaded. [    1.823863] Loading module verification certificates [
> 1.825422] MODSIGN: Loaded cert 'Fedora kernel signing key:
> 5d4d3db151807b6ebce83001a24319304d98d21f' [    1.825440] registered
> taskstats version 1 [    1.826548]   Magic number: 13:688:296 [
> 1.826589] tty tty29: hash matches [    1.826701] rtc_cmos 00:07:
> setting system clock to 2013-01-25 20:17:19 UTC (1359145039) [
> 1.829590] Freeing unused kernel memory: 1068k freed [    1.830056]
> Write protecting the kernel read-only data: 12288k [    1.837216]
> Freeing unused kernel memory: 1776k freed [    1.843238] Freeing
> unused kernel memory: 1404k freed [    1.919162] usb 1-6: new
> high-speed USB device number 4 using ehci_hcd [    2.047904] usb
> 1-6: New USB device found, idVendor=05ac, idProduct=850a [
> 2.047913] usb 1-6: New USB device strings: Mfr=1, Product=2,
> SerialNumber=3 [    2.047920] usb 1-6: Product: Built-in iSight [
> 2.047926] usb 1-6: Manufacturer: Apple Inc. [    2.047932] usb 1-6:
> SerialNumber: CCGB1CTXMGDF9KF0 [    2.186358] systemd[1]: systemd
> 197 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +IMA
> +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ) [    2.186878]
> systemd[1]: Running in initial RAM disk. [    2.187329] systemd[1]:
> No hostname configured. [    2.187347] systemd[1]: Set hostname to
> <localhost>. [    2.187671] systemd[1]: Initializing machine ID
> from random generator. [    2.211774] systemd[1]: Starting
> Encrypted Volumes. [    2.211819] systemd[1]: Reached target
> Encrypted Volumes. [    2.211987] systemd[1]: Starting udev Kernel
> Socket. [    2.212103] systemd[1]: Listening on udev Kernel
> Socket. [    2.212245] systemd[1]: Starting udev Control Socket. [
> 2.212340] systemd[1]: Listening on udev Control Socket. [
> 2.212371] systemd[1]: Starting Journal Socket. [    2.212513]
> systemd[1]: Listening on Journal Socket. [    2.212550] systemd[1]:
> Starting dracut cmdline hook... [    2.222357] systemd[1]: Started
> Load Kernel Modules. [    2.222415] systemd[1]: Starting Journal
> Service... [    2.232434] systemd[1]: Started Journal Service. [
> 2.243221] systemd[1]: Starting Sockets. [    2.243271] systemd[1]:
> Reached target Sockets. [    2.243312] systemd[1]: Starting Swap. [
> 2.243344] systemd[1]: Reached target Swap. [    2.243373]
> systemd[1]: Starting Local File Systems. [    2.243404] systemd[1]:
> Reached target Local File Systems. [    2.495408] RPC: Registered
> named UNIX socket transport module. [    2.495413] RPC: Registered
> udp transport module. [    2.495415] RPC: Registered tcp transport
> module. [    2.495417] RPC: Registered tcp NFSv4.1 backchannel
> transport module. [    2.522049] usb 3-3: new full-speed USB device
> number 2 using ohci_hcd [    2.609510] systemd-udevd[150]: starting
> version 197 [    2.723061] usb 3-3: New USB device found,
> idVendor=05ac, idProduct=0242 [    2.723074] usb 3-3: New USB
> device strings: Mfr=1, Product=2, SerialNumber=0 [    2.723082] usb
> 3-3: Product: Apple Internal Keyboard / Trackpad [    2.723088] usb
> 3-3: Manufacturer: Apple Inc. [    2.738838] input: Apple Inc.
> Apple Internal Keyboard / Trackpad as
> /devices/pci0000:00/0000:00:04.0/usb3/3-3/3-3:1.0/input/input4 [
> 2.738946] apple 0003:05AC:0242.0001: input,hidraw0: USB HID v1.11
> Keyboard [Apple Inc. Apple Internal Keyboard / Trackpad] on
> usb-0000:00:04.0-3/input0 [    2.751160] apple 0003:05AC:0242.0002:
> hidraw1: USB HID v1.11 Device [Apple Inc. Apple Internal Keyboard /
> Trackpad] on usb-0000:00:04.0-3/input1 [    2.812819] [Firmware
> Bug]: ACPI(IGPU) defines _DOD but not _DOS [    2.813030] ACPI:
> Video Device [IGPU] (multi-head: yes  rom: no  post: no) [
> 2.813219] input: Video Bus as
> /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:2a/LNXVIDEO:00/input/input5
>
> 
[    2.851173] [drm] Initialized drm 1.1.0 20060810
> [    2.862539] wmi: Mapper loaded [    2.891890] checking generic
> (c0010000 600000) vs hw (c0000000 10000000) [    2.891895] fb:
> conflicting fb hw usage nouveaufb vs EFI VGA - removing generic
> driver [    2.891920] Console: switching to colour dummy device
> 80x25 [    2.898579] nouveau 0000:02:00.0: setting latency timer to
> 64 [    2.898591] nouveau 0000:02:00.0: enabling device (0006 ->
> 0007) [    2.898808] ACPI: PCI Interrupt Link [LGPU] enabled at IRQ
> 16 [    2.899735] nouveau  [  DEVICE][0000:02:00.0] BOOT0  :
> 0x0af100a2 [    2.899741] nouveau  [  DEVICE][0000:02:00.0]
> Chipset: MCP89 (NVAF) [    2.899744] nouveau  [
> DEVICE][0000:02:00.0] Family : NV50 [    2.907202] nouveau  [
> VBIOS][0000:02:00.0] checking PRAMIN for image... [    2.967292]
> nouveau  [   VBIOS][0000:02:00.0] ... appears to be valid [
> 2.967297] nouveau  [   VBIOS][0000:02:00.0] using image from
> PRAMIN [    2.967448] nouveau  [   VBIOS][0000:02:00.0] BIT
> signature found [    2.967452] nouveau  [   VBIOS][0000:02:00.0]
> version 70.89.13.00 [    2.987849] nouveau  [
> MXM][0000:02:00.0] no VBIOS data, nothing to do [    3.070924] usb
> 3-5: new full-speed USB device number 3 using ohci_hcd [
> 3.071110] nouveau  [     PFB][0000:02:00.0] RAM type: stolen system
> memory [    3.071114] nouveau  [     PFB][0000:02:00.0] RAM size:
> 256 MiB [    3.270052] usb 3-5: New USB device found,
> idVendor=0a5c, idProduct=4500 [    3.270059] usb 3-5: New USB
> device strings: Mfr=1, Product=2, SerialNumber=0 [    3.270062] usb
> 3-5: Product: BRCM2070 Hub [    3.270066] usb 3-5: Manufacturer:
> Apple Inc. [    3.273080] hub 3-5:1.0: USB hub found [    3.276036]
> hub 3-5:1.0: 3 ports detected [    3.589058] usb 3-5.1: new
> full-speed USB device number 4 using ohci_hcd [    3.689046] usb
> 3-5.1: New USB device found, idVendor=05ac, idProduct=820a [
> 3.689051] usb 3-5.1: New USB device strings: Mfr=0, Product=0,
> SerialNumber=0 [    3.698446] input: HID 05ac:820a as
> /devices/pci0000:00/0000:00:04.0/usb3/3-5/3-5.1/3-5.1:1.0/input/input6
>
> 
[    3.698545] hid-generic 0003:05AC:820A.0003: input,hidraw2: USB HID
v1.11 Keyboard [HID 05ac:820a] on usb-0000:00:04.0-5.1/input0
> [    3.720083] nouveau W[    PCE0][0000:02:00.0] disabled, PCE0=1
> to enable [    3.720219] [TTM] Zone  kernel: Available graphics
> memory: 1893110 kiB [    3.720222] [TTM] Initializing pool
> allocator [    3.720228] [TTM] Initializing DMA pool allocator [
> 3.722468] nouveau  [     DRM] VRAM: 256 MiB [    3.722474] nouveau
> [     DRM] GART: 512 MiB [    3.722480] nouveau  [     DRM] BIT
> BIOS found [    3.722484] nouveau  [     DRM] Bios version
> 70.89.13.00 [    3.722489] nouveau  [     DRM] TMDS table version
> 2.0 [    3.722492] nouveau  [     DRM] DCB version 4.0 [
> 3.722495] nouveau  [     DRM] DCB outp 00: 040001b6 0f220010 [
> 3.722499] nouveau  [     DRM] DCB outp 01: 020112a6 0f220010 [
> 3.722502] nouveau  [     DRM] DCB outp 02: 02011262 00020010 [
> 3.722505] nouveau  [     DRM] DCB conn 00: 00002047 [    3.722509]
> nouveau  [     DRM] DCB conn 01: 00101146 [    3.735376] [drm]
> Supports vblank timestamp caching Rev 1 (10.10.2010). [
> 3.735379] [drm] No driver support for vblank timestamp query. [
> 4.904369] nouveau  [     DRM] 4 available performance level(s) [
> 4.904375] nouveau  [     DRM] 0: core 405MHz shader 405MHz memory
> 405MHz voltage 900mV [    4.904380] nouveau  [     DRM] 1: core
> 450MHz shader 810MHz memory 450MHz voltage 900mV [    4.904385]
> nouveau  [     DRM] 2: core 450MHz shader 810MHz memory 450MHz
> voltage 900mV [    4.904389] nouveau  [     DRM] 3: core 450MHz
> shader 950MHz memory 450MHz voltage 900mV [    4.904393] nouveau  [
> DRM] c: core 405MHz shader 810MHz [    4.905014] [sched_delayed]
> sched: RT throttling activated [    4.906050] usb 3-5.2: new
> full-speed USB device number 5 using ohci_hcd [    5.004884]
> nouveau  [     DRM] MM: using M2MF for buffer copies [    5.049071]
> nouveau  [     DRM] allocated 1366x768 fb: 0x50000, bo
> ffff8801330e1400 [    5.049179] fbcon: nouveaufb (fb0) is primary
> device [    5.085068] usb 3-5.2: New USB device found,
> idVendor=05ac, idProduct=820b [    5.085073] usb 3-5.2: New USB
> device strings: Mfr=0, Product=0, SerialNumber=0 [    5.091844]
> Console: switching to colour frame buffer device 170x48 [
> 5.094132] fb0: nouveaufb frame buffer device [    5.094134] drm:
> registered panic notifier [    5.094140] [drm] Initialized nouveau
> 1.1.0 20120801 for 0000:02:00.0 on minor 0 [    5.094407] input:
> HID 05ac:820b as
> /devices/pci0000:00/0000:00:04.0/usb3/3-5/3-5.2/3-5.2:1.0/input/input7
>
> 
[    5.094548] hid-generic 0003:05AC:820B.0004: input,hidraw3: USB HID
v1.11 Mouse [HID 05ac:820b] on usb-0000:00:04.0-5.2/input0
> [    5.167041] usb 3-5.3: new full-speed USB device number 6 using
> ohci_hcd [    5.232371] bio: create slab <bio-1> at 1 [
> 5.277056] usb 3-5.3: New USB device found, idVendor=05ac,
> idProduct=821b [    5.277064] usb 3-5.3: New USB device strings:
> Mfr=1, Product=2, SerialNumber=0 [    5.277068] usb 3-5.3: Product:
> Bluetooth USB Host Controller [    5.277071] usb 3-5.3:
> Manufacturer: Apple Inc. [    5.323104] EXT4-fs (dm-1): mounted
> filesystem with ordered data mode. Opts: (null) [    5.401812]
> EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts:
> (null) [    5.763329] systemd-journald[55]: Received SIGTERM [
> 5.885206] type=1404 audit(1359145043.558:2): enforcing=1
> old_enforcing=0 auid=4294967295 ses=4294967295 [    5.943829]
> SELinux: 2048 avtab hash slots, 94354 rules. [    5.966668]
> SELinux: 2048 avtab hash slots, 94354 rules. [    6.259136]
> SELinux:  9 users, 15 roles, 4357 types, 236 bools, 1 sens, 1024
> cats [    6.259142] SELinux:  83 classes, 94354 rules [
> 6.266534] SELinux:  Completing initialization. [    6.266539]
> SELinux:  Setting up existing superblocks. [    6.266548] SELinux:
> initialized (dev sysfs, type sysfs), uses genfs_contexts [
> 6.266555] SELinux: initialized (dev rootfs, type rootfs), uses
> genfs_contexts [    6.266574] SELinux: initialized (dev bdev, type
> bdev), uses genfs_contexts [    6.266581] SELinux: initialized (dev
> proc, type proc), uses genfs_contexts [    6.266596] SELinux:
> initialized (dev tmpfs, type tmpfs), uses transition SIDs [
> 6.266622] SELinux: initialized (dev devtmpfs, type devtmpfs), uses
> transition SIDs [    6.267748] SELinux: initialized (dev sockfs,
> type sockfs), uses task SIDs [    6.267755] SELinux: initialized
> (dev debugfs, type debugfs), uses genfs_contexts [    6.270178]
> SELinux: initialized (dev pipefs, type pipefs), uses task SIDs [
> 6.270189] SELinux: initialized (dev anon_inodefs, type
> anon_inodefs), uses genfs_contexts [    6.270194] SELinux:
> initialized (dev devpts, type devpts), uses transition SIDs [
> 6.270218] SELinux: initialized (dev hugetlbfs, type hugetlbfs),
> uses transition SIDs [    6.270230] SELinux: initialized (dev
> mqueue, type mqueue), uses transition SIDs [    6.270240] SELinux:
> initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts [
> 6.270271] SELinux: initialized (dev sysfs, type sysfs), uses
> genfs_contexts [    6.271248] SELinux: initialized (dev securityfs,
> type securityfs), uses genfs_contexts [    6.271254] SELinux:
> initialized (dev efivarfs, type efivarfs), uses genfs_contexts [
> 6.271280] SELinux: initialized (dev tmpfs, type tmpfs), uses
> transition SIDs [    6.271289] SELinux: initialized (dev tmpfs,
> type tmpfs), uses transition SIDs [    6.271433] SELinux:
> initialized (dev tmpfs, type tmpfs), uses transition SIDs [
> 6.271476] SELinux: initialized (dev cgroup, type cgroup), uses
> genfs_contexts [    6.271483] SELinux: initialized (dev cgroup,
> type cgroup), uses genfs_contexts [    6.271496] SELinux:
> initialized (dev cgroup, type cgroup), uses genfs_contexts [
> 6.271540] SELinux: initialized (dev cgroup, type cgroup), uses
> genfs_contexts [    6.271557] SELinux: initialized (dev cgroup,
> type cgroup), uses genfs_contexts [    6.271566] SELinux:
> initialized (dev cgroup, type cgroup), uses genfs_contexts [
> 6.271572] SELinux: initialized (dev cgroup, type cgroup), uses
> genfs_contexts [    6.271580] SELinux: initialized (dev cgroup,
> type cgroup), uses genfs_contexts [    6.271595] SELinux:
> initialized (dev cgroup, type cgroup), uses genfs_contexts [
> 6.271604] SELinux: initialized (dev rpc_pipefs, type rpc_pipefs),
> uses genfs_contexts [    6.271621] SELinux: initialized (dev dm-1,
> type ext4), uses xattr [    6.303388] type=1403
> audit(1359145043.976:3): policy loaded auid=4294967295
> ses=4294967295 [    6.316105] systemd[1]: Successfully loaded
> SELinux policy in 435ms 804us. [    6.381883] systemd[1]:
> Relabelled /dev and /run in 36ms 388us. [    6.652383] SELinux:
> initialized (dev autofs, type autofs), uses genfs_contexts [
> 6.666772] SELinux: initialized (dev hugetlbfs, type hugetlbfs),
> uses transition SIDs [    6.675341] SELinux: initialized (dev
> tmpfs, type tmpfs), uses transition SIDs [    6.738960]
> systemd-udevd[376]: starting version 197 [    6.833189] EXT4-fs
> (dm-1): re-mounted. Opts: (null) [    6.892625] SELinux:
> initialized (dev configfs, type configfs), uses genfs_contexts [
> 6.921422] tun: Universal TUN/TAP device driver, 1.6 [    6.921426]
> tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com> [
> 7.058681] shpchp: Standard Hot Plug PCI Controller Driver version:
> 0.4 [    7.095517] microcode: CPU0 sig=0x1067a, pf=0x80,
> revision=0xa07 [    7.101008] microcode: CPU0 updated to revision
> 0xa0b, date = 2010-09-28 [    7.109593] bcma: bus0: Found chip with
> id 0xA8D8, rev 0x01 and package 0x08 [    7.109616] bcma: bus0:
> Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, class
> 0x0) [    7.109634] bcma: bus0: Core 1 found: IEEE 802.11 (manuf
> 0x4BF, id 0x812, rev 0x17, class 0x0) [    7.109668] bcma: bus0:
> Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0) [
> 7.114302] microcode: CPU1 sig=0x1067a, pf=0x80, revision=0xa07 [
> 7.115009] microcode: CPU1 updated to revision 0xa0b, date =
> 2010-09-28 [    7.123091] microcode: Microcode Update Driver: v2.00
> <tigran@aivazian.fsnet.co.uk>, Peter Oruba [    7.159026] bcma:
> bus0: Bus registered [    7.228647] snd_hda_intel 0000:00:08.0:
> enabling device (0000 -> 0002) [    7.228972] ACPI: PCI Interrupt
> Link [LAZA] enabled at IRQ 19 [    7.229059] hda_intel: Disabling
> MSI [    7.229062] hda_intel: position_fix set to 1 for device
> 10de:cb89 [    7.229164] snd_hda_intel 0000:00:08.0: setting
> latency timer to 64 [    7.241509] ALSA
> sound/pci/hda/hda_intel.c:1628 Enable delay in RIRB handling [
> 7.263663] input: bcm5974 as
> /devices/pci0000:00/0000:00:04.0/usb3/3-3/3-3:1.2/input/input8 [
> 7.263973] usbcore: registered new interface driver bcm5974 [
> 7.332838] Bluetooth: Core ver 2.16 [    7.332871] NET: Registered
> protocol family 31 [    7.332874] Bluetooth: HCI device and
> connection manager initialized [    7.332885] Bluetooth: HCI socket
> layer initialized [    7.332889] Bluetooth: L2CAP socket layer
> initialized [    7.332897] Bluetooth: SCO socket layer initialized 
> [    7.344328] usbcore: registered new interface driver btusb [
> 7.351492] media: Linux media interface: v0.10 [    7.361078] Linux
> video capture interface: v2.00 [    7.366438] cfg80211: Calling
> CRDA to update world regulatory domain [    7.385058] usb 3-5.1:
> USB disconnect, device number 4 [    7.385231] cfg80211: World
> regulatory domain updated: [    7.385234] cfg80211:   (start_freq -
> end_freq @ bandwidth), (max_antenna_gain, max_eirp) [    7.385237]
> cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000
> mBm) [    7.385240] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000
> KHz), (300 mBi, 2000 mBm) [    7.385243] cfg80211:   (2474000 KHz -
> 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm) [    7.385246]
> cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000
> mBm) [    7.385248] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000
> KHz), (300 mBi, 2000 mBm) [    7.414857] applesmc: key=322 fan=1
> temp=27 index=26 acc=0 lux=0 kbd=0 [    7.423911] uvcvideo: Found
> UVC 1.00 device Built-in iSight (05ac:850a) [    7.431237] input:
> Built-in iSight as
> /devices/pci0000:00/0000:00:04.1/usb1/1-6/1-6:1.0/input/input9 [
> 7.431554] usbcore: registered new interface driver uvcvideo [
> 7.431557] USB Video Class driver (1.1.1) [    7.459877] brcmsmac
> bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 21 [    7.513473]
> ieee80211 phy0: Selected rate control algorithm 'minstrel_ht' [
> 7.518721] Adding 3801084k swap on /dev/mapper/fedora-swap.
> Priority:-1 extents:1 across:3801084k SS [    7.535050] usb 3-5.2:
> USB disconnect, device number 5 [    7.637761] ALSA
> sound/pci/hda/hda_auto_parser.c:318 autoconfig: line_outs=2
> (0xb/0xa/0x0/0x0/0x0) type:speaker [    7.637767] ALSA
> sound/pci/hda/hda_auto_parser.c:322    speaker_outs=0
> (0x0/0x0/0x0/0x0/0x0) [    7.637770] ALSA
> sound/pci/hda/hda_auto_parser.c:326    hp_outs=1
> (0x9/0x0/0x0/0x0/0x0) [    7.637773] ALSA
> sound/pci/hda/hda_auto_parser.c:327    mono: mono_out=0x0 [
> 7.637776] ALSA sound/pci/hda/hda_auto_parser.c:330
> dig-out=0x10/0x0 [    7.637778] ALSA
> sound/pci/hda/hda_auto_parser.c:331    inputs: [    7.637781] ALSA
> sound/pci/hda/hda_auto_parser.c:335      Mic=0xd [    7.639461]
> EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts:
> (null) [    7.639683] SELinux: initialized (dev sda2, type ext4),
> uses xattr [    7.674634] SELinux: initialized (dev sda1, type
> hfsplus), uses genfs_contexts [    7.883280] input: HDA NVidia
> HDMI/DP,pcm=8 as
> /devices/pci0000:00/0000:00:08.0/sound/card0/input10 [    7.883524]
> input: HDA NVidia HDMI/DP,pcm=7 as
> /devices/pci0000:00/0000:00:08.0/sound/card0/input11 [    7.883717]
> input: HDA NVidia HDMI/DP,pcm=3 as
> /devices/pci0000:00/0000:00:08.0/sound/card0/input12 [    7.883908]
> input: HDA NVidia Headphone as
> /devices/pci0000:00/0000:00:08.0/sound/card0/input13 [    8.186825]
> EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts:
> (null) [    8.186839] SELinux: initialized (dev dm-2, type ext4),
> uses xattr [    8.382602] systemd-journald[406]: Received SIGUSR1 [
> 8.798596] Bluetooth: BNEP (Ethernet Emulation) ver 1.3 [
> 8.798601] Bluetooth: BNEP filters: protocol multicast [
> 8.798614] Bluetooth: BNEP socket layer initialized [    8.822744]
> Bluetooth: RFCOMM TTY layer initialized [    8.822764] Bluetooth:
> RFCOMM socket layer initialized [    8.822766] Bluetooth: RFCOMM
> ver 1.11 [    9.149697] Loading iSCSI transport class v2.0-870. [
> 9.185557] iscsi: registered transport (tcp) [    9.240372]
> ip6_tables: (C) 2000-2006 Netfilter Core Team [    9.294356]
> Ebtables v2.0 registered [    9.365221] iscsi: registered transport
> (iser) [    9.400465] libcxgbi:libcxgbi_init_module: tag itt
> 0x1fff, 13 bits, age 0xf, 4 bits. [    9.400471]
> libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0. [
> 9.508168] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled:
> false (implement) [    9.508182] ieee80211 phy0: brcms_ops_config:
> change power-save mode: false (implement) [    9.522696] IPv6:
> ADDRCONF(NETDEV_UP): wlan0: link is not ready [    9.529471]
> Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010) [    9.529958]
> iscsi: registered transport (cxgb3i) [    9.606464] Chelsio T4
> iSCSI Driver cxgb4i v0.9.1 (Aug. 2010) [    9.607916] iscsi:
> registered transport (cxgb4i) [    9.617810] nouveau W[
> PCE0][0000:02:00.0] disabled, PCE0=1 to enable [    9.643803] cnic:
> Broadcom NetXtreme II CNIC Driver cnic v2.5.14 (Sep 30, 2012) [
> 9.651162] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr
> 25, 2012) [    9.667370] iscsi: registered transport (bnx2i) [
> 9.721297] nf_conntrack version 0.5.0 (16384 buckets, 65536 max) [
> 9.733520] iscsi: registered transport (be2iscsi) [    9.733526] In
> beiscsi_module_init, tt=ffffffffa06ed000 [   10.736366] nouveau W[
> PCE0][0000:02:00.0] disabled, PCE0=1 to enable [   12.289251]
> nouveau W[    PCE0][0000:02:00.0] disabled, PCE0=1 to enable [
> 17.634442] wlan0: authenticate with 10:9a:dd:89:4c:84 [
> 17.653618] wlan0: direct probe to 10:9a:dd:89:4c:84 (try 1/3) [
> 17.854059] wlan0: send auth to 10:9a:dd:89:4c:84 (try 2/3) [
> 17.854544] wlan0: authenticated [   17.856057] wlan0: associate
> with 10:9a:dd:89:4c:84 (try 1/3) [   17.859052] wlan0: RX AssocResp
> from 10:9a:dd:89:4c:84 (capab=0x511 status=0 aid=3) [   17.859471]
> ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated [
> 17.859483] ieee80211 phy0: brcms_ops_bss_info_changed: arp
> filtering: enabled true, count 0 (implement) [   17.859490]
> ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: true
> (implement) [   17.859516] wlan0: associated [   17.859545] IPv6:
> ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready [   17.859776]
> cfg80211: Calling CRDA for country: FI [   17.877610] cfg80211:
> Regulatory domain changed to country: FI [   17.877616] cfg80211:
> (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp) [
> 17.877619] cfg80211:   (2402000 KHz - 2482000 KHz @ 40000 KHz),
> (N/A, 2000 mBm) [   17.877621] cfg80211:   (5170000 KHz - 5250000
> KHz @ 40000 KHz), (N/A, 2000 mBm) [   17.877624] cfg80211:
> (5250000 KHz - 5330000 KHz @ 40000 KHz), (N/A, 2000 mBm) [
> 17.877627] cfg80211:   (5490000 KHz - 5710000 KHz @ 40000 KHz),
> (N/A, 2700 mBm) [   17.880113] wlan0: Limiting TX power to 30 (30 -
> 0) dBm as advertised by 10:9a:dd:89:4c:84 [   18.018462] ieee80211
> phy0: brcms_ops_bss_info_changed: arp filtering: enabled true,
> count 1 (implement) [   20.264533] cgroup: libvirtd (1226) created
> nested cgroup for controller "memory" which has incomplete
> hierarchy support. Nested cgroups may change behavior in the
> future. [   20.264543] cgroup: "memory" requires setting
> use_hierarchy to 1 on the root. [   20.264715] cgroup: libvirtd
> (1226) created nested cgroup for controller "devices" which has
> incomplete hierarchy support. Nested cgroups may change behavior in
> the future. [   20.264817] cgroup: libvirtd (1226) created nested
> cgroup for controller "freezer" which has incomplete hierarchy
> support. Nested cgroups may change behavior in the future. [
> 20.264905] cgroup: libvirtd (1226) created nested cgroup for
> controller "blkio" which has incomplete hierarchy support. Nested
> cgroups may change behavior in the future. [   25.876145] fuse init
> (API version 7.20) [   25.885175] SELinux: initialized (dev fuse,
> type fuse), uses genfs_contexts [   27.411152] nouveau W[
> PCE0][0000:02:00.0] disabled, PCE0=1 to enable [   37.599098]
> ------------[ cut here ]------------ [   37.599163] WARNING: at
> drivers/net/wireless/brcm80211/brcmsmac/main.c:7993
> brcms_c_wait_for_tx_completion+0x99/0xb0 [brcmsmac]() [
> 37.599167] Hardware name: MacBookAir3,1 [   37.599171] Modules
> linked in: fuse ebtable_nat ipt_MASQUERADE nf_conntrack_netbios_ns
> nf_conntrack_broadcast ip6table_mangle ip6t_REJECT
> nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat
> iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 be2iscsi
> xt_conntrack nf_conntrack iscsi_boot_sysfs bnx2i cnic uio cxgb4i
> cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser ebtable_filter rdma_cm
> ib_addr iw_cm ib_cm ebtables ip6table_filter ip6_tables ib_sa
> ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi
> rfcomm bnep snd_hda_codec_hdmi nls_utf8 hfsplus
> snd_hda_codec_cirrus arc4 brcmsmac cordic brcmutil uvcvideo
> mac80211 videobuf2_vmalloc videobuf2_memops videobuf2_core cfg80211
> videodev media btusb bluetooth joydev rfkill bcm5974 coretemp
> snd_hda_intel snd_hda_codec snd_hwdep snd_seq applesmc [
> 37.599287]  snd_seq_device input_polldev snd_pcm bcma microcode
> snd_page_alloc snd_timer snd shpchp soundcore apple_bl vhost_net
> tun macvtap macvlan kvm_intel kvm uinput nouveau mxm_wmi wmi
> i2c_algo_bit drm_kms_helper ttm drm i2c_core video sunrpc [
> 37.599342] Pid: 6, comm: kworker/u:0 Not tainted
> 3.7.2-204.fc18.x86_64 #1 [   37.599347] Call Trace: [   37.599366]
> [<ffffffff8105e67f>] warn_slowpath_common+0x7f/0xc0 [   37.599375]
> [<ffffffff8105e6da>] warn_slowpath_null+0x1a/0x20 [   37.599402]
> [<ffffffffa051ec99>] brcms_c_wait_for_tx_completion+0x99/0xb0
> [brcmsmac] [   37.599423]  [<ffffffffa05116bb>]
> brcms_ops_flush+0x3b/0x60 [brcmsmac] [   37.599478]
> [<ffffffffa04317ed>] ieee80211_mgd_probe_ap_send+0x13d/0x200
> [mac80211] [   37.599508]  [<ffffffffa03dc5ee>] ?
> cfg80211_cqm_rssi_notify+0x2e/0x40 [cfg80211] [   37.599549]
> [<ffffffffa042fb91>] ? ieee80211_cqm_rssi_notify+0x41/0xa0
> [mac80211] [   37.599590]  [<ffffffffa0431e5c>]
> ieee80211_mgd_probe_ap.part.25+0x12c/0x150 [mac80211] [
> 37.599631]  [<ffffffffa0431eaa>]
> ieee80211_sta_monitor_work+0x2a/0x30 [mac80211] [   37.599642]
> [<ffffffff8107a487>] process_one_work+0x147/0x490 [   37.599683]
> [<ffffffffa0431e80>] ? ieee80211_mgd_probe_ap.part.25+0x150/0x150
> [mac80211] [   37.599691]  [<ffffffff8107cd1e>]
> worker_thread+0x15e/0x450 [   37.599700]  [<ffffffff8107cbc0>] ?
> busy_worker_rebind_fn+0x110/0x110 [   37.599709]
> [<ffffffff81081c80>] kthread+0xc0/0xd0 [   37.599716]
> [<ffffffff8107a8c0>] ? rescuer_thread+0xb0/0x240 [   37.599727]
> [<ffffffff81010000>] ?
> ftrace_raw_event_xen_mmu_flush_tlb_others+0x50/0xe0 [   37.599735]
> [<ffffffff81081bc0>] ? kthread_create_on_node+0x120/0x120 [
> 37.599746]  [<ffffffff8163de2c>] ret_from_fork+0x7c/0xb0 [
> 37.599754]  [<ffffffff81081bc0>] ?
> kthread_create_on_node+0x120/0x120 [   37.599759] ---[ end trace
> c70b3d4e5e865a15 ]--- [   41.060113] nouveau W[
> PCE0][0000:02:00.0] disabled, PCE0=1 to enable
> 
