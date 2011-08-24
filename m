From: Paul Menzel <pm.debian@googlemail.com>
Subject: Re: Bug#584724: linux-image-2.6.32-5-amd64: NETDEV WATCHDOG: eth0
 (via-rhine): transmit queue 0 timed out
Date: Wed, 24 Aug 2011 12:39:27 +0200
Message-ID: <1314182368.3628.18.camel@mattotaupa>
References: <20100606024158.12393.82960.reportbug@buzz.bailey>
	 <1275859426.10677.69.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-v7VQpLwkVwo3l+VQmPlw"
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	"R. Scott Bailey" <scott@cartasoft.com>
To: Ben Hutchings <ben@decadent.org.uk>, 584724@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37870 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab1HXKji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 06:39:38 -0400
Received: by bke11 with SMTP id 11so778764bke.19
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 03:39:37 -0700 (PDT)
In-Reply-To: <1275859426.10677.69.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v7VQpLwkVwo3l+VQmPlw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Version: 2.6.32-35

Dear, Roger, dear Roger, dear Ben and dear NetDev folks,


Am Sonntag, den 06.06.2010, 22:23 +0100 schrieb Ben Hutchings:

> There's some kind of TX lock-up bug in via-rhine (or more likely certain
> variants of the hardware).
>=20
> On Sat, 2010-06-05 at 22:41 -0400, R. Scott Bailey wrote:
> > Package: linux-2.6
> > Version: 2.6.32-15
> > Severity: normal
> >=20
> > This appears to be the same bug as:
> >  https://bugzilla.kernel.org/show_bug.cgi?id=3D11663

[=E2=80=A6]

I experienced the same problem today when there probably was high usage
of the network interface `eth0` and the network suddenly stopped
working.

        [ 1649.816037] ------------[ cut here ]------------
        [ 1649.816061] WARNING: at /tmp/buildd/linux-2.6-2.6.32/debian/buil=
d/source_i386_none/net/sched/sch_generic.c:261 dev_watchdog+0xd2/0x16f()
        [ 1649.816068] Hardware name: System Product Name
        [ 1649.816074] NETDEV WATCHDOG: eth0 (via-rhine): transmit queue 0 =
timed out
        [ 1649.816078] Modules linked in: binfmt_misc via drm ip6table_filt=
er ip6_tables iptable_filter ip_tables x_tables powernow_k8 cpufreq_conserv=
ative cpufreq_userspace cpufreq_stats cpufreq_powersave reiserfs xfs export=
fs fuse kvm_amd kvm loop firewire_sbp2 firewire_core crc_itu_t snd_hda_code=
c_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss s=
nd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_se=
q_device amd64_edac_mod psmouse snd edac_core soundcore parport_pc i2c_viap=
ro serio_raw snd_page_alloc k8temp edac_mce_amd evdev parport asus_atk0110 =
shpchp i2c_core pci_hotplug processor button ext3 jbd mbcache sha256_generi=
c aes_x86_64 aes_generic cbc dm_crypt dm_mod raid1 md_mod sg usbhid hid sd_=
mod crc_t10dif sr_mod cdrom ata_generic sata_via uhci_hcd pata_via libata e=
hci_hcd thermal thermal_sys usbcore nls_base scsi_mod via_rhine mii [last u=
nloaded: scsi_wait_scan]
        [ 1649.816213] Pid: 0, comm: swapper Not tainted 2.6.32-5-amd64 #1
        [ 1649.816218] Call Trace:
        [ 1649.816223]  <IRQ>  [<ffffffff8125ff97>] ? dev_watchdog+0xd2/0x1=
6f
        [ 1649.816238]  [<ffffffff8125ff97>] ? dev_watchdog+0xd2/0x16f
        [ 1649.816248]  [<ffffffff8104de1c>] ? warn_slowpath_common+0x77/0x=
a3
        [ 1649.816255]  [<ffffffff8125fec5>] ? dev_watchdog+0x0/0x16f
        [ 1649.816262]  [<ffffffff8104dea4>] ? warn_slowpath_fmt+0x51/0x59
        [ 1649.816272]  [<ffffffff811904ec>] ? rb_insert_color+0xba/0xe2
        [ 1649.816281]  [<ffffffff81041b4f>] ? enqueue_task_fair+0x3e/0x82
        [ 1649.816292]  [<ffffffff810164f7>] ? sched_clock+0x5/0x8
        [ 1649.816299]  [<ffffffff8125fe99>] ? netif_tx_lock+0x3d/0x69
        [ 1649.816309]  [<ffffffff8124ae2e>] ? netdev_drivername+0x3b/0x40
        [ 1649.816316]  [<ffffffff8125ff97>] ? dev_watchdog+0xd2/0x16f
        [ 1649.816324]  [<ffffffff81050065>] ? release_task+0x2ed/0x3fa
        [ 1649.816335]  [<ffffffff8105a3ff>] ? run_timer_softirq+0x1c9/0x26=
8
        [ 1649.816344]  [<ffffffff81068f5b>] ? sched_clock_local+0x13/0x74
        [ 1649.816354]  [<ffffffff81053b83>] ? __do_softirq+0xdd/0x1a6
        [ 1649.816363]  [<ffffffff8102425e>] ? lapic_next_event+0x18/0x1d
        [ 1649.816371]  [<ffffffff81011cac>] ? call_softirq+0x1c/0x30
        [ 1649.816378]  [<ffffffff8101322b>] ? do_softirq+0x3f/0x7c
        [ 1649.816385]  [<ffffffff810539f3>] ? irq_exit+0x36/0x76
        [ 1649.816393]  [<ffffffff81024d2c>] ? smp_apic_timer_interrupt+0x8=
7/0x95
        [ 1649.816400]  [<ffffffff81011673>] ? apic_timer_interrupt+0x13/0x=
20
        [ 1649.816405]  <EOI>  [<ffffffff8102c570>] ? native_safe_halt+0x2/=
0x3
        [ 1649.816421]  [<ffffffff810171ad>] ? default_idle+0x34/0x51
        [ 1649.816428]  [<ffffffff81017539>] ? c1e_idle+0xf5/0xfb
        [ 1649.816437]  [<ffffffff8100feb1>] ? cpu_idle+0xa2/0xda
        [ 1649.816448]  [<ffffffff814eb140>] ? early_idt_handler+0x0/0x71
        [ 1649.816456]  [<ffffffff814ebcdd>] ? start_kernel+0x3dc/0x3e8
        [ 1649.816464]  [<ffffffff814eb3b7>] ? x86_64_start_kernel+0xf9/0x1=
06
        [ 1649.816470] ---[ end trace 60fe8c71761322c0 ]---
        [ 1649.816620] eth0: Transmit timed out, status 1003, PHY status 79=
6d, resetting...
        [ 1649.817405] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1661.816170] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1661.816939] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1673.816203] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1673.816989] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1689.816172] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1689.816923] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1711.816175] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1711.816949] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1725.816228] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1725.816981] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1743.816171] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1743.816935] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1759.816238] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1759.816990] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1769.816216] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1769.817194] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1779.816170] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1779.816982] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1789.816208] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1789.816961] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1801.816211] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1801.816963] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
        [ 1815.816171] eth0: Transmit timed out, status 0003, PHY status 79=
6d, resetting...
        [ 1815.816938] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1

Looking at the files in `/var/log` I only found that one occurrence and
I do not remember having it seen before. So it will be hard to
reproduce.

Did anyone look further into this issue? What is the best way to
proceed?


Thanks,

Paul


-- Package-specific info:
** Version:
Linux version 2.6.32-5-amd64 (Debian 2.6.32-35) (dannf@debian.org) (gcc ver=
sion 4.3.5 (Debian 4.3.5-4) ) #1 SMP Mon Jun 13 05:49:32 UTC 2011

** Command line:
BOOT_IMAGE=3D/vmlinuz-2.6.32-5-amd64 root=3D/dev/mapper/speicher-root ro qu=
iet

** Not tainted

** Kernel log:
[    1.969559] usb 3-2: Manufacturer: ALCOR
[    1.969655] usb 3-2: configuration #1 chosen from 1 choice
[    1.972620] hub 3-2:1.0: USB hub found
[    1.974547] hub 3-2:1.0: 4 ports detected
[   34.436426] PM: Starting manual resume from disk
[   34.436431] PM: Resume from partition 253:2
[   34.436433] PM: Checking hibernation image.
[   34.437267] PM: Error -22 checking image file
[   34.437271] PM: Resume from disk failed.
[   34.469253] kjournald starting.  Commit interval 5 seconds
[   34.469280] EXT3-fs: mounted filesystem with ordered data mode.
[   36.067027] <30>udevd[479]: starting version 172
[   36.820001] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0E:00/input/input2
[   36.820017] ACPI: Sleep Button [SLPB]
[   36.820094] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0C:00/input/input3
[   36.820098] ACPI: Power Button [PWRB]
[   36.820172] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input4
[   36.820176] ACPI: Power Button [PWRF]
[   36.869497] processor LNXCPU:00: registered as cooling_device0
[   36.869722] processor LNXCPU:01: registered as cooling_device1
[   36.995431] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   37.195935] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   37.199434] k8temp 0000:00:18.3: Temperature readouts might be wrong - c=
heck erratum #141
[   37.305311] parport_pc 00:04: reported by Plug and Play ACPI
[   37.305357] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   37.309018] EDAC MC: Ver: 2.1.0 Jun 13 2011
[   37.392788] EDAC amd64_edac:  Ver: 3.2.0 Jun 13 2011
[   37.393206] EDAC amd64: ECC is enabled by BIOS.
[   37.393260] EDAC MC: Rev F or later detected
[   37.393339] EDAC MC0: Giving out device to 'amd64_edac' 'RevF': DEV 0000=
:00:18.2
[   37.393366] EDAC PCI0: Giving out device to module 'amd64_edac' controll=
er 'EDAC PCI controller': DEV '0000:00:18.2' (POLLED)
[   38.078767]   alloc irq_desc for 17 on node 0
[   38.078771]   alloc kstat_irqs on node 0
[   38.078780] HDA Intel 0000:20:01.0: PCI INT A -> GSI 17 (level, low) -> =
IRQ 17
[   38.078848] HDA Intel 0000:20:01.0: setting latency timer to 64
[   38.078852] HDA Intel 0000:20:01.0: PCI: Disallowing DAC for device
[   38.165465] input: HDA Digital PCBeep as /devices/pci0000:20/0000:20:01.=
0/input/input5
[   38.229088] input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i804=
2/serio1/input/input6
[   38.654956] ioctl32(fsck.ext3:873): Unknown cmd fd(3) cmd(0000127c){t:12=
;sz:0} arg(ffbb5b78) on /dev/dm-1
[   38.733323] EXT3 FS on dm-1, internal journal
[   39.260842] loop: module loaded
[   39.347705] kvm: Nested Virtualization enabled
[   40.978782] Adding 4194296k swap on /dev/mapper/speicher-swap.  Priority=
:-1 extents:1 across:4194296k=20
[   40.991004] ioctl32(fsck.ext3:1112): Unknown cmd fd(3) cmd(0000127c){t:1=
2;sz:0} arg(ffc7e7c8) on /dev/md0
[   41.096680] ioctl32(fsck.ext3:1113): Unknown cmd fd(3) cmd(0000127c){t:1=
2;sz:0} arg(ff829398) on /dev/dm-6
[   41.611917] ioctl32(fsck.ext3:1118): Unknown cmd fd(3) cmd(0000127c){t:1=
2;sz:0} arg(ffb6a518) on /dev/dm-3
[   42.107186] ioctl32(fsck.ext3:1122): Unknown cmd fd(3) cmd(0000127c){t:1=
2;sz:0} arg(ffa58358) on /dev/dm-4
[   42.831820] fuse init (API version 7.13)
[   43.030563] kjournald starting.  Commit interval 5 seconds
[   43.062644] EXT3 FS on md0, internal journal
[   43.062650] EXT3-fs: mounted filesystem with ordered data mode.
[   43.361324] kjournald starting.  Commit interval 5 seconds
[   43.425153] EXT3 FS on dm-6, internal journal
[   43.425160] EXT3-fs: mounted filesystem with ordered data mode.
[   43.537165] SGI XFS with ACLs, security attributes, realtime, large bloc=
k/inode numbers, no debug enabled
[   43.538260] SGI XFS Quota Management subsystem
[   43.624320] XFS mounting filesystem dm-7
[   43.830882] Ending clean XFS mount for filesystem: dm-7
[   44.042558] XFS mounting filesystem dm-8
[   44.368648] Ending clean XFS mount for filesystem: dm-8
[   44.432261] REISERFS (device dm-5): found reiserfs format "3.6" with sta=
ndard journal
[   44.432311] REISERFS (device dm-5): using ordered data mode
[   44.441915] REISERFS (device dm-5): journal params: device dm-5, size 81=
92, journal first block 18, max trans len 1024, max batch 900, max commit a=
ge 30, max trans age 30
[   44.443486] REISERFS (device dm-5): checking transaction log (dm-5)
[   44.460023] REISERFS (device dm-5): Using r5 hash to sort names
[   44.620051] kjournald starting.  Commit interval 5 seconds
[   44.620626] EXT3 FS on dm-3, internal journal
[   44.620633] EXT3-fs: mounted filesystem with ordered data mode.
[   44.664746] kjournald starting.  Commit interval 5 seconds
[   44.665047] EXT3 FS on dm-4, internal journal
[   44.665054] EXT3-fs: mounted filesystem with ordered data mode.
[   47.302027] powernow-k8: Found 1 AMD Athlon(tm) X2 Dual Core Processor B=
E-2350 processors (2 cpu cores) (version 2.20.00)
[   47.302087] powernow-k8:    0 : fid 0xd (2100 MHz), vid 0xe
[   47.302089] powernow-k8:    1 : fid 0xc (2000 MHz), vid 0xf
[   47.302092] powernow-k8:    2 : fid 0xa (1800 MHz), vid 0x11
[   47.302094] powernow-k8:    3 : fid 0x2 (1000 MHz), vid 0x16
[   47.504022] Clocksource tsc unstable (delta =3D -92800302 ns)
[  129.063621] ip_tables: (C) 2000-2006 Netfilter Core Team
[  129.189058] ip6_tables: (C) 2000-2006 Netfilter Core Team
[  137.998574] [drm] Initialized drm 1.1.0 20060810
[  138.158226]   alloc irq_desc for 16 on node 0
[  138.158234]   alloc kstat_irqs on node 0
[  138.158256] pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  138.159938] [drm] Initialized via 2.11.1 20070202 for 0000:01:00.0 on mi=
nor 0
[  138.161083] ioctl32(Xorg:2429): Unknown cmd fd(11) cmd(c0106407){t:'d';s=
z:16} arg(ffe72770) on /dev/dri/card0
[  138.161128] ioctl32(Xorg:2429): Unknown cmd fd(11) cmd(c0106407){t:'d';s=
z:16} arg(ffe72770) on /dev/dri/card0
[  138.161144] ioctl32(Xorg:2429): Unknown cmd fd(11) cmd(c0086401){t:'d';s=
z:8} arg(ffe72768) on /dev/dri/card0
[  138.231724] ioctl32(Xorg:2429): Unknown cmd fd(11) cmd(c0246400){t:'d';s=
z:36} arg(08823f10) on /dev/dri/card0
[  138.252608] ioctl32(Xorg:2429): Unknown cmd fd(11) cmd(c0246400){t:'d';s=
z:36} arg(08823f10) on /dev/dri/card0
[  142.791066] mtrr: no MTRR for d0000000,8000000 found
[  146.113242] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0246400){t:'d';s=
z:36} arg(08665f10) on /dev/dri/card0
[  146.113308] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0246400){t:'d';s=
z:36} arg(08665f10) on /dev/dri/card0
[  146.123386] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0106407){t:'d';s=
z:16} arg(ffd8c0b0) on /dev/dri/card0
[  146.123407] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0106407){t:'d';s=
z:16} arg(ffd8c0b0) on /dev/dri/card0
[  146.123416] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0086401){t:'d';s=
z:8} arg(ffd8c0a8) on /dev/dri/card0
[  146.184393] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0246400){t:'d';s=
z:36} arg(08665f10) on /dev/dri/card0
[  146.194407] ioctl32(Xorg:2515): Unknown cmd fd(11) cmd(c0246400){t:'d';s=
z:36} arg(08665f10) on /dev/dri/card0
[  185.172076] hda-intel: IRQ timing workaround is activated for card #0. S=
uggest a bigger bdl_pos_adj.
[  327.111398] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  337.652026] eth0: no IPv6 routers present

** Model information
sys_vendor: System manufacturer
product_name: System Product Name
product_version: System Version
chassis_vendor: Chassis Manufacture
chassis_version: Chassis Version
bios_vendor: American Megatrends Inc.
bios_version: 0304  =20
board_vendor: ASUSTeK Computer INC.
board_name: M2V-MX SE
board_version: Rev x.xx

** Loaded modules:
Module                  Size  Used by
binfmt_misc             6351  1=20
via                    32815  0=20
drm                   141751  1 via
ip6table_filter         2384  0=20
ip6_tables             14883  1 ip6table_filter
iptable_filter          2258  0=20
ip_tables              13691  1 iptable_filter
x_tables               12685  2 ip6_tables,ip_tables
powernow_k8            10946  2=20
cpufreq_conservative     5162  0=20
cpufreq_userspace       1960  0=20
cpufreq_stats           2659  0=20
cpufreq_powersave        902  0=20
reiserfs              193068  1=20
xfs                   433495  2=20
exportfs                3090  1 xfs
fuse                   50492  1=20
kvm_amd                31830  0=20
kvm                   213832  1 kvm_amd
loop                   11591  0=20
firewire_sbp2          11354  0=20
firewire_core          36576  1 firewire_sbp2
crc_itu_t               1307  1 firewire_core
snd_hda_codec_realtek   235122  1=20
snd_hda_intel          20003  2=20
snd_hda_codec          53892  2 snd_hda_codec_realtek,snd_hda_intel
snd_hwdep               5220  1 snd_hda_codec
snd_pcm_oss            32415  0=20
snd_mixer_oss          12478  1 snd_pcm_oss
snd_pcm                60151  3 snd_hda_intel,snd_hda_codec,snd_pcm_oss
snd_seq_midi            4256  0=20
snd_rawmidi            15323  1 snd_seq_midi
snd_seq_midi_event      4628  1 snd_seq_midi
snd_seq                41153  2 snd_seq_midi,snd_seq_midi_event
snd_timer              15486  2 snd_pcm,snd_seq
snd_seq_device          4493  3 snd_seq_midi,snd_rawmidi,snd_seq
amd64_edac_mod         13758  0=20
snd                    45966  15 snd_hda_codec_realtek,snd_hda_intel,snd_hd=
a_codec,snd_hwdep,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_rawmidi,snd_seq,snd=
_timer,snd_seq_device
psmouse                49905  0=20
evdev                   7352  14=20
edac_core              29197  3 amd64_edac_mod
parport_pc             18855  0=20
soundcore               4566  1 snd
i2c_viapro              5483  0=20
parport                27682  1 parport_pc
snd_page_alloc          6137  2 snd_hda_intel,snd_pcm
k8temp                  3283  0=20
asus_atk0110            7686  0=20
shpchp                 26232  0=20
edac_mce_amd            6401  1 amd64_edac_mod
serio_raw               3752  0=20
i2c_core               15403  2 drm,i2c_viapro
pci_hotplug            21203  1 shpchp
processor              29807  1 powernow_k8
button                  4650  0=20
ext3                  106086  5=20
jbd                    36653  1 ext3
mbcache                 5050  1 ext3
sha256_generic          8644  2=20
aes_x86_64              7340  2=20
aes_generic            25714  1 aes_x86_64
cbc                     2507  1=20
dm_crypt               10600  1=20
dm_mod                 53162  30 dm_crypt
raid1                  18207  2=20
md_mod                 73200  3 raid1
sg                     23861  0=20
usbhid                 33148  0=20
hid                    63145  1 usbhid
sr_mod                 12250  0=20
cdrom                  28631  1 sr_mod
sd_mod                 29617  3=20
crc_t10dif              1276  1 sd_mod
ata_generic             3239  0=20
uhci_hcd               18457  0=20
pata_via                7429  0=20
ehci_hcd               31825  0=20
sata_via                7896  2=20
libata                133008  3 ata_generic,pata_via,sata_via
thermal                11610  0=20
thermal_sys            11942  2 processor,thermal
via_rhine              17259  0=20
mii                     3210  1 via_rhine
usbcore               121970  4 usbhid,uhci_hcd,ehci_hcd
nls_base                6377  1 usbcore
scsi_mod              125813  5 firewire_sbp2,sg,sr_mod,sd_mod,libata

** Network interface configuration:

auto lo
iface lo inet loopback

allow-hotplug eth0

** Network status:
*** IP interfaces and addresses:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state =
UNKNOWN qlen 1000
    link/ether 00:1e:8c:b9:4b:2a brd ff:ff:ff:ff:ff:ff
    inet 192.168.178.21/24 brd 192.168.178.255 scope global eth0
    inet6 fe80::21e:8cff:feb9:4b2a/64 scope link=20
       valid_lft forever preferred_lft forever

*** Device statistics:
Inter-|   Receive                                                |  Transmi=
t
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    =
packets errs drop fifo colls carrier compressed
    lo: 8656508   14542    0    0    0     0          0         0  8656508 =
  14542    0    0    0     0       0          0
  eth0:169205475  144684    0    0    0     0          0         0  9204417=
  100047    0    0    0     0       0          0

*** Protocol statistics:
Ip:
    158979 total packets received
    0 forwarded
    0 incoming packets discarded
    158979 incoming packets delivered
    114296 requests sent out
    72 dropped because of missing route
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    1 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 1
IcmpMsg:
        OutType3: 1
Tcp:
    2282 active connections openings
    0 passive connection openings
    6 failed connection attempts
    187 connection resets received
    6 connections established
    139466 segments received
    94270 segments send out
    222 segments retransmited
    0 bad segments received.
    2153 resets sent
Udp:
    19438 packets received
    1 packets to unknown port received.
    0 packet receive errors
    19727 packets sent
UdpLite:
TcpExt:
    245 TCP sockets finished time wait in fast timer
    6 time wait sockets recycled by time stamp
    2181 delayed acks sent
    Quick ack mode was activated 8 times
    61 packets directly queued to recvmsg prequeue.
    988 bytes directly received in process context from prequeue
    114317 packet headers predicted
    1 packets header predicted and directly queued to user
    2128 acknowledgments not containing data payload received
    9176 predicted acknowledgments
    7 congestion windows recovered without slow start after partial ack
    72 other TCP timeouts
    8 DSACKs sent for old packets
    2 DSACKs received
    375 connections reset due to unexpected data
    910 connections reset due to early user close
    22 connections aborted due to timeout
    TCPDSACKIgnoredNoUndo: 2
IpExt:
    InMcastPkts: 110
    OutMcastPkts: 112
    InBcastPkts: 1
    InOctets: 175828154
    OutOctets: 16448126
    InMcastOctets: 7513
    OutMcastOctets: 7913
    InBcastOctets: 576

*** Device features:
eth0: 0x0
lo: 0x13865

** PCI devices:
00:00.0 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [11=
06:0336]
	Subsystem: VIA Technologies, Inc. K8M890CE Host Bridge [1106:0336]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Region 0: Memory at <ignored> (32-bit, prefetchable)
	Capabilities: <access denied>
	Kernel driver in use: agpgart-amd64

00:00.1 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [11=
06:1336]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8297]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes

00:00.2 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [11=
06:2336]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8297]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes

00:00.3 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [11=
06:3336]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8297]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes

00:00.4 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [11=
06:4336]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8297]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes

00:00.5 PIC [0800]: VIA Technologies, Inc. K8M890CE I/O APIC Interrupt Cont=
roller [1106:5336] (prog-if 20 [IO(X)-APIC])
	Subsystem: ASUSTeK Computer Inc. Device [1043:8297]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes

00:00.7 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [11=
06:7336]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes

00:01.0 PCI bridge [0604]: VIA Technologies, Inc. VT8237 PCI bridge [K8T800=
/K8T890 South] [1106:b188] (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D0
	Memory behind bridge: fa000000-fbefffff
	Prefetchable memory behind bridge: d0000000-dfffffff
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

00:02.0 PCI bridge [0604]: VIA Technologies, Inc. K8T890 PCI to PCI Bridge =
Controller [1106:a238] (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: 80000000-801fffff
	Prefetchable memory behind bridge: 0000000080200000-00000000803fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:03.0 PCI bridge [0604]: VIA Technologies, Inc. K8T890 PCI to PCI Bridge =
Controller [1106:c238] (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=3D0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: 80400000-805fffff
	Prefetchable memory behind bridge: 0000000080600000-00000000807fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:0f.0 IDE interface [0101]: VIA Technologies, Inc. Device [1106:5372] (pr=
og-if 8f [Master SecP SecO PriP PriO])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Interrupt: pin B routed to IRQ 21
	Region 0: I/O ports at ec00 [size=3D8]
	Region 1: I/O ports at e880 [size=3D4]
	Region 2: I/O ports at e800 [size=3D8]
	Region 3: I/O ports at e480 [size=3D4]
	Region 4: I/O ports at e400 [size=3D16]
	Region 5: I/O ports at e000 [size=3D256]
	Capabilities: <access denied>
	Kernel driver in use: sata_via

00:0f.1 IDE interface [0101]: VIA Technologies, Inc. VT82C586A/B/VT82C686/A=
/B/VT823x/A/C PIPC Bus Master IDE [1106:0571] (rev 07) (prog-if 8a [Master =
SecP PriP])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 32
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=3D=
8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=3D=
1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=3D=
8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [size=3D=
1]
	Region 4: I/O ports at fc00 [size=3D16]
	Capabilities: <access denied>
	Kernel driver in use: pata_via

00:10.0 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.=
1 Controller [1106:3038] (rev b0) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 20
	Region 4: I/O ports at d480 [size=3D32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:10.1 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.=
1 Controller [1106:3038] (rev b0) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 22
	Region 4: I/O ports at d800 [size=3D32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:10.2 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.=
1 Controller [1106:3038] (rev b0) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin C routed to IRQ 21
	Region 4: I/O ports at d880 [size=3D32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:10.3 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.=
1 Controller [1106:3038] (rev b0) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin D routed to IRQ 23
	Region 4: I/O ports at dc00 [size=3D32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:10.4 USB Controller [0c03]: VIA Technologies, Inc. USB 2.0 [1106:3104] (=
rev 90) (prog-if 20 [EHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin C routed to IRQ 21
	Region 0: Memory at f9fffc00 (32-bit, non-prefetchable) [size=3D256]
	Capabilities: <access denied>
	Kernel driver in use: ehci_hcd

00:11.0 ISA bridge [0601]: VIA Technologies, Inc. VT8237S PCI to ISA Bridge=
 [1106:3372]
	Subsystem: ASUSTeK Computer Inc. Device [1043:827c]
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Capabilities: <access denied>

00:11.7 Host bridge [0600]: VIA Technologies, Inc. VT8251 Ultra VLINK Contr=
oller [1106:287e]
	Subsystem: VIA Technologies, Inc. Device [1106:337e]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 128
	Capabilities: <access denied>

00:12.0 Ethernet controller [0200]: VIA Technologies, Inc. VT6102 [Rhine-II=
] [1106:3065] (rev 7c)
	Subsystem: ASUSTeK Computer Inc. A7V600-X Motherboard [1043:80ed]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (750ns min, 2000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 23
	Region 0: I/O ports at d000 [size=3D256]
	Region 1: Memory at f9fff800 (32-bit, non-prefetchable) [size=3D256]
	Capabilities: <access denied>
	Kernel driver in use: via-rhine

00:13.0 Host bridge [0600]: VIA Technologies, Inc. VT8237A Host Bridge [110=
6:337b]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>

00:13.1 PCI bridge [0604]: VIA Technologies, Inc. VT8237A PCI to PCI Bridge=
 [1106:337a] (prog-if 01 [Subtractive decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=3D00, secondary=3D04, subordinate=3D04, sec-latency=3D0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

00:18.0 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opter=
on] HyperTransport Technology Configuration [1022:1100]
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Capabilities: <access denied>

00:18.1 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opter=
on] Address Map [1022:1101]
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opter=
on] DRAM Controller [1022:1102]
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Kernel driver in use: amd64_edac

00:18.3 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opter=
on] Miscellaneous Control [1022:1103]
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Capabilities: <access denied>
	Kernel driver in use: k8temp

01:00.0 VGA compatible controller [0300]: VIA Technologies, Inc. K8M890CE/K=
8N890CE [Chrome 9] [1106:3230] (rev 11) (prog-if 00 [VGA controller])
	Subsystem: ASUSTeK Computer Inc. Device [1043:8297]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (500ns min)
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at d0000000 (32-bit, prefetchable) [size=3D256M]
	Region 1: Memory at fa000000 (32-bit, non-prefetchable) [size=3D16M]
	Expansion ROM at fbef0000 [disabled] [size=3D64K]
	Capabilities: <access denied>

20:01.0 Audio device [0403]: VIA Technologies, Inc. VT1708/A [Azalia HDAC] =
(VIA High Definition Audio Controller) [1106:3288] (rev 10)
	Subsystem: ASUSTeK Computer Inc. Device [1043:8290]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at fbffc000 (64-bit, non-prefetchable) [size=3D16K]
	Capabilities: <access denied>
	Kernel driver in use: HDA Intel


** USB devices:
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 002 Device 002: ID 046d:c312 Logitech, Inc. DeLuxe 250 Keyboard
Bus 003 Device 002: ID 058f:9254 Alcor Micro Corp. Hub


-- System Information:
Debian Release: wheezy/sid
  APT prefers unstable
  APT policy: (500, 'unstable'), (500, 'testing'), (500, 'stable'), (1, 'ex=
perimental')
Architecture: i386 (x86_64)

Kernel: Linux 2.6.32-5-amd64 (SMP w/2 CPU cores)
Locale: LANG=3Dde_DE.UTF-8, LC_CTYPE=3Dde_DE.UTF-8 (charmap=3DUTF-8)
Shell: /bin/sh linked to /bin/bash

Versions of packages linux-image-2.6.32-5-amd64 depends on:
ii  debconf [debconf-2.0]         1.5.41     Debian configuration managemen=
t sy
ii  initramfs-tools [linux-initra 0.99       tools for generating an initra=
mfs
ii  linux-base                    3.3        Linux image base package
ii  module-init-tools             3.16-1     tools for managing Linux kerne=
l mo

Versions of packages linux-image-2.6.32-5-amd64 recommends:
ii  firmware-linux-free           3          Binary firmware for various dr=
iver
iu  libc6-i686                    2.13-17    Embedded GNU C Library: Shared=
 lib

Versions of packages linux-image-2.6.32-5-amd64 suggests:
pn  grub | lilo                   <none>     (no description available)
pn  linux-doc-2.6.32              <none>     (no description available)

Versions of packages linux-image-2.6.32-5-amd64 is related to:
pn  firmware-bnx2                 <none>     (no description available)
pn  firmware-bnx2x                <none>     (no description available)
pn  firmware-ipw2x00              <none>     (no description available)
pn  firmware-ivtv                 <none>     (no description available)
pn  firmware-iwlwifi              <none>     (no description available)
pn  firmware-linux                <none>     (no description available)
pn  firmware-linux-nonfree        <none>     (no description available)
pn  firmware-qlogic               <none>     (no description available)
pn  firmware-ralink               <none>     (no description available)
pn  xen-hypervisor                <none>     (no description available)

-- debconf information:
  linux-image-2.6.32-5-amd64/postinst/missing-firmware-2.6.32-5-amd64:
  linux-image-2.6.32-5-amd64/postinst/bootloader-error-2.6.32-5-amd64:
  linux-image-2.6.32-5-amd64/prerm/would-invalidate-boot-loader-2.6.32-5-am=
d64: true
  linux-image-2.6.32-5-amd64/postinst/ignoring-do-bootloader-2.6.32-5-amd64=
:
  shared/kernel-image/really-run-bootloader: true
  linux-image-2.6.32-5-amd64/postinst/depmod-error-initrd-2.6.32-5-amd64: f=
alse
  linux-image-2.6.32-5-amd64/prerm/removing-running-kernel-2.6.32-5-amd64: =
true
  linux-image-2.6.32-5-amd64/postinst/bootloader-test-error-2.6.32-5-amd64:

--=-v7VQpLwkVwo3l+VQmPlw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAk5U1N8ACgkQPX1aK2wOHVif1QCeNgGAk/S/Q+JMq2sieuvkTXeT
3eUAmwfoLgssdR9HBq+LsaBmXDtj7tqT
=tcw0
-----END PGP SIGNATURE-----

--=-v7VQpLwkVwo3l+VQmPlw--
