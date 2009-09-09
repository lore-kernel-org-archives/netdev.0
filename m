From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: [AX25] kernel panic
Date: Thu, 10 Sep 2009 00:28:00 +0200
Message-ID: <4AA82BF0.7040203@upmc.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000109030607030706030307"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:56136 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752354AbZIIW2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 18:28:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000109030607030706030307
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ralf,

Here is a set of not so frequent kernel panics captured via netconsole
that seem related to AX25 timer. 

Regards,

Bernard Pidoux

--------------000109030607030706030307
Content-Type: text/plain;
 name="kernel_panic_AX25"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="kernel_panic_AX25"

------------------------
sam. ao=C3=BBt  8 22:08:26 CEST 2009
------------------------
BUG: unable to handle kernel paging request at ffff880004c90648
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 206063 PMD 7e2067 PTE 4c90160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm i2c_viapro snd_timer =
snd_page_alloc snd_mixer_oss snd i2c_core soundcore sr_mod 8139cp 8139too=
 mii shpchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_con=
servative cpufreq_powersave acpi_cpufreq freq_table floppy sg rtc_cmos th=
ermal via_agp processor evdev button pata_via ata_generic ide_pci_generic=
 pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0018:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff880004c90400 RCX: 0000000000000058
RDX: ffffe200009cb3d8 RSI: ffffffff8067f060 RDI: ffff880004c90618
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 0000000000000490
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff880004c90618
R13: ffff880004c90400 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000000000000(0000) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff880004c90648 CR3: 0000000074843000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8068c000, task ffffffff806323=
60)
Stack:
 ffff880004c90400 ffff880004c90400 ffff880004c90400 ffffffffa035bb30
 ffffffff80717e30 ffffffffa035b850 ffffffff80717e60 ffffffffa035edb4
 ffff880004c90400 ffff880004c90400 0000000000000000 ffffffffa035bb30
Call Trace:
 <IRQ> <0> [<ffffffffa035bb30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa035b850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa035edb4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa035bb30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa035b045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffff80217c56>] ? read_tsc+0x16/0x40
 [<ffffffffa035bb55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0> [<ffffffff80218afd>] ? mwait_idle+0x5d/0x70
 [<ffffffff8020fdd2>] ? enter_idle+0x22/0x30
 [<ffffffff8020fe2e>] ? cpu_idle+0x4e/0x80
 [<ffffffff804eb5cd>] ? rest_init+0x5d/0x70
Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 8d 54 07 1=
0 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <48> c7 47 =
30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff880004c90648
---[ end trace 366e8cf762bbf316 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..BUG: unable to handle kernel paging request at f=
fff88001bbee248
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 206063 PMD 899067 PTE 1bbee160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm 8139cp snd_timer snd_=
page_alloc snd_mixer_oss snd soundcore sr_mod 8139too mii i2c_viapro i2c_=
core shpchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_con=
servative cpufreq_powersave acpi_cpufreq freq_table thermal processor flo=
ppy rtc_cmos via_agp button sg evdev pata_via ata_generic ide_pci_generic=
 pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0018:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff88001bbee000 RCX: 0000000000000058
RDX: ffffe2000060cbb8 RSI: ffffffff8067f060 RDI: ffff88001bbee218
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 00000000000003ee
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff88001bbee218
R13: ffff88001bbee000 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000000000000(0000) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff88001bbee248 CR3: 00000000296e7000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8068c000, task ffffffff806323=
60)
Stack:
 ffff88001bbee000 ffff88001bbee000 ffff88001bbee000 ffffffffa0355b30
 ffffffff80717e30 ffffffffa0355850 ffffffff80717e60 ffffffffa0358db4
 ffff88001bbee000 ffff88001bbee000 0000000000000000 ffffffffa0355b30
Call Trace:
 <IRQ> <0> [<ffffffffa0355b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0355850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa0358db4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa0355b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0355045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffff80217c56>] ? read_tsc+0x16/0x40
 [<ffffffffa0355b55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0> [<ffffffff80218afd>] ? mwait_idle+0x5d/0x70
 [<ffffffff8020fdd2>] ? enter_idle+0x22/0x30
 [<ffffffff8020fe2e>] ? cpu_idle+0x4e/0x80
 [<ffffffff804eb5cd>] ? rest_init+0x5d/0x70
Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 8d 54 07 1=
0 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <48> c7 47 =
30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff88001bbee248
---[ end trace b7e0c620509cd638 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..------------------------
jeu. ao=C3=BBt 13 00:13:13 CEST 2009
------------------------
BUG: unable to handle kernel paging request at ffff880071c80e48
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 9bc067 PMD b4b067 PTE 71c80160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0=20
Modules linked in: loop netconsole netrom mkiss rose ax25 nfsd exportfs n=
fs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_c=
odec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_s=
eq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_pa=
ge_alloc snd_mixer_oss 8139cp i2c_viapro snd soundcore sr_mod 8139too i2c=
_core mii shpchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufre=
q_conservative cpufreq_powersave acpi_cpufreq freq_table thermal floppy r=
tc_cmos processor via_agp button sg evdev pata_via ata_generic ide_pci_ge=
neric pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0018:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff880071c80c00 RCX: 0000000000000058
RDX: ffffe200010313d8 RSI: ffffffff8067f060 RDI: ffff880071c80e18
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 0000000000000480
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff880071c80e18
R13: ffff880071c80c00 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000000000000(0000) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff880071c80e48 CR3: 000000007a11c000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8068c000, task ffffffff806323=
60)
Stack:
 ffff880071c80c00 ffff880071c80c00 ffff880071c80c00 ffffffffa0358b30
 ffffffff80717e30 ffffffffa0358850 ffffffff80717e60 ffffffffa035bdb4
 ffff880071c80c00 ffff880071c80c00 0000000000000000 ffffffffa0358b30
Call Trace:
 <IRQ> <0> [<ffffffffa0358b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0358850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa035bdb4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa0358b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0358045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffff80217c56>] ? read_tsc+0x16/0x40
 [<ffffffffa0358b55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0> [<ffffffff80218afd>] ? mwait_idle+0x5d/0x70
 [<ffffffff8020fdd2>] ? enter_idle+0x22/0x30
 [<ffffffff8020fe2e>] ? cpu_idle+0x4e/0x80
 [<ffffffff804eb5cd>] ? rest_init+0x5d/0x70
Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 8d 54 07 1=
0 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <48> c7 47 =
30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff880071c80e48
---[ end trace d516331eccbfb939 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..------------------------
sam. ao=C3=BBt 15 10:15:34 CEST 2009
------------------------
  =20
------------------------
sam. ao=C3=BBt 15 10:16:32 CEST 2009
------------------------
 =20
-------------------------------
sam. ao=C3=BBt 15 13:11:53 CEST 2009
-------------------------------
 =20
-------------------------------
sam. ao=C3=BBt 15 13:16:21 CEST 2009
-------------------------------
  =20
-------------------------------
sam. ao=C3=BBt 15 14:36:50 CEST 2009
-------------------------------
  =20
-------------------------------
Sun Aug 16 04:03:12 CEST 2009
-------------------------------
  =20
-------------------------------
Mon Aug 17 04:03:21 CEST 2009
-------------------------------
 =20
-------------------------------
lun. ao=C3=BBt 17 12:43:33 CEST 2009
-------------------------------
  =20
-------------------------------
lun. ao=C3=BBt 17 14:03:50 CEST 2009
-------------------------------
  =20
-------------------------------
Tue Aug 18 04:03:17 CEST 2009
-------------------------------
  =20
-------------------------------
Wed Aug 19 04:03:22 CEST 2009
-------------------------------
  =20
-------------------------------
Thu Aug 20 04:03:24 CEST 2009
-------------------------------
 =20
-------------------------------
jeu. ao=C3=BBt 20 14:21:57 CEST 2009
-------------------------------
  =20
-------------------------------
jeu. ao=C3=BBt 20 15:42:15 CEST 2009
-------------------------------
general protection fault: 0000 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/class/vc/vcsa6/dev
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_al=
loc i2c_viapro snd_mixer_oss snd i2c_core soundcore sr_mod 8139too mii sh=
pchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservati=
ve cpufreq_powersave acpi_cpufreq freq_table floppy sg rtc_cmos via_agp t=
hermal evdev processor button pata_via ata_generic ide_pci_generic pata_a=
cpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 30904, comm: astropulse_5.06 Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffffa034fb3d>]  [<ffffffffa034fb3d>] ax25_heartbeat_expir=
y+0xd/0x60 [ax25]
RSP: 0000:ffffffff80717ea0  EFLAGS: 00010206
RAX: ffff880061829fd8 RBX: ffff88006f59b000 RCX: ffffffffa034fb30
RDX: 6e75203a7473696c RSI: 0000000000000e3f RDI: ffff88006f59b000
RBP: ffffffff80717ea0 R08: ffff88006f59b250 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000100
R13: ffffffff8075a600 R14: ffffffffa034fb30 R15: ffffffff80717ed0
FS:  0000000001493860(0063) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f771ebbd000 CR3: 000000006b867000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process astropulse_5.06 (pid: 30904, threadinfo ffff880061828000, task ff=
ff8800618641a0)
Stack:
 ffffffff80717f10 ffffffff8024976c ffffffff8075c210 ffffffff8075be10
 ffffffff8075ba10 ffffffff8075b610 ffff88006f512970 ffff88006f512970
 ffffffff8025f8ff 0000000000000008 0000000000000001 0000000000000100
Call Trace:
 <IRQ> <0> [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0>Code: 80 7a 58 00 66 90 74 da c9 0f 1f 44 00 00 c3 66 66 66 66 =
66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8b 57 28 48 89 e5 48 85 d2 74 0c <=
8b> 42 50 85 c0 78 11 83 f8 01 7f 17 0f 1f 80 00 00 00 00 e8 fb=20
RIP  [<ffffffffa034fb3d>] ax25_heartbeat_expiry+0xd/0x60 [ax25]
 RSP <ffffffff80717ea0>
---[ end trace 0dee287bd3d290a3 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..  =20
-------------------------------
Fri Aug 21 04:03:18 CEST 2009
-------------------------------
  =20
-------------------------------
Sat Aug 22 04:03:24 CEST 2009
-------------------------------
  =20
-------------------------------
Sun Aug 23 04:03:27 CEST 2009
-------------------------------
  =20
-------------------------------
Mon Aug 24 04:03:26 CEST 2009
-------------------------------
  =20
-------------------------------
Tue Aug 25 04:03:23 CEST 2009
-------------------------------
  =20
-------------------------------
Wed Aug 26 04:03:25 CEST 2009
-------------------------------
general protection fault: 0000 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/class/vc/vcsa12/dev
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_al=
loc snd_mixer_oss snd 8139too mii i2c_viapro soundcore i2c_core sr_mod sh=
pchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservati=
ve cpufreq_powersave acpi_cpufreq freq_table floppy sg rtc_cmos via_agp t=
hermal evdev processor button pata_via ata_generic ide_pci_generic pata_a=
cpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 28253, comm: astropulse_5.06 Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffffa0342ae8>]  [<ffffffffa0342ae8>] ax25_t1timer_expiry+=
0x8/0x50 [ax25]
RSP: 0000:ffffffff80717ea0  EFLAGS: 00010246
RAX: ffff880074023fd8 RBX: ffff88007bc90000 RCX: ffffffffa0342ae0
RDX: a86496acda711900 RSI: 0000000000000000 RDI: ffff88007bc90000
RBP: ffffffff80717ea0 R08: ffff88007bc90078 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000100
R13: ffffffff8075a600 R14: ffffffffa0342ae0 R15: ffffffff80717ed0
FS:  000000000224b860(0063) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fa029a4e000 CR3: 000000007e8e9000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process astropulse_5.06 (pid: 28253, threadinfo ffff880074022000, task ff=
ff8800714c2bc0)
Stack:
 ffffffff80717f10 ffffffff8024976c ffffffff8075c210 ffffffff8075be10
 ffffffff8075ba10 ffffffff8075b610 ffffffff80717ed0 ffffffff80717ed0
 ffffffff8025f8ff 0000000000000008 0000000000000001 0000000000000100
Call Trace:
 <IRQ> <0> [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0>Code: 44 00 00 75 e7 80 7a 58 00 66 90 74 da c9 0f 1f 44 00 00 =
c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8b 57 28 48 89 e5 <=
8b> 42 50 85 c0 78 0a 83 f8 01 7f 14 e8 e7 f1 ff ff c9 66 0f 1f=20
RIP  [<ffffffffa0342ae8>] ax25_t1timer_expiry+0x8/0x50 [ax25]
 RSP <ffffffff80717ea0>
---[ end trace 963e5b19794631dc ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..  =20
-------------------------------
Thu Aug 27 04:03:22 CEST 2009
-------------------------------
  =20
-------------------------------
Fri Aug 28 04:03:26 CEST 2009
-------------------------------
BUG: unable to handle kernel paging request at ffff880077ca0e48
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 9bc067 PMD b7b067 PTE 77ca0160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/class/vc/vcsa6/dev
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_al=
loc snd_mixer_oss snd i2c_viapro soundcore i2c_core sr_mod 8139too mii sh=
pchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservati=
ve cpufreq_powersave acpi_cpufreq freq_table floppy sg rtc_cmos via_agp t=
hermal evdev processor button pata_via ata_generic ide_pci_generic pata_a=
cpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 30841, comm: setiathome-5.28 Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0000:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff880077ca0c00 RCX: 0000000000000058
RDX: ffffe20001a29a48 RSI: ffffffff8067f060 RDI: ffff880077ca0e18
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 00000000000004a0
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff880077ca0e18
R13: ffff880077ca0c00 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000041b93940(0063) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff880077ca0e48 CR3: 000000006e1fc000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process setiathome-5.28 (pid: 30841, threadinfo ffff88007957c000, task ff=
ff8800750cabc0)
Stack:
 ffff880077ca0c00 ffff880077ca0c00 ffff880077ca0c00 ffffffffa034fb30
 ffffffff80717e30 ffffffffa034f850 ffffffff80717e60 ffffffffa0352db4
 ffff880077ca0c00 ffff880077ca0c00 0000000000000000 ffffffffa034fb30
Call Trace:
 <IRQ> <0> [<ffffffffa034fb30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa034f850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa0352db4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa034fb30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa034f045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffff80217c56>] ? read_tsc+0x16/0x40
 [<ffffffffa034fb55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0>Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 =
8d 54 07 10 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <=
48> c7 47 30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff880077ca0e48
---[ end trace 2278e28e8ee624db ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..  =20
-------------------------------
Sat Aug 29 04:03:23 CEST 2009
-------------------------------
  =20
-------------------------------
Sun Aug 30 04:03:21 CEST 2009
-------------------------------
  =20
-------------------------------
Mon Aug 31 04:03:24 CEST 2009
-------------------------------
BUG: unable to handle kernel paging request at ffff88006eca8a48
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 9bc067 PMD b33067 PTE 6eca8160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_al=
loc snd_mixer_oss snd i2c_viapro 8139too i2c_core soundcore sr_mod mii sh=
pchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservati=
ve cpufreq_powersave acpi_cpufreq freq_table via_agp rtc_cmos floppy ther=
mal processor button sg evdev pata_via ata_generic ide_pci_generic pata_a=
cpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0018:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff88006eca8800 RCX: 0000000000000058
RDX: ffffe200017e8f68 RSI: ffffffff8067f060 RDI: ffff88006eca8a18
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 00000000000004a8
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff88006eca8a18
R13: ffff88006eca8800 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000000000000(0000) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff88006eca8a48 CR3: 000000006e00b000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8068c000, task ffffffff806323=
60)
Stack:
 ffff88006eca8800 ffff88006eca8800 ffff88006eca8800 ffffffffa0345b30
 ffffffff80717e30 ffffffffa0345850 ffffffff80717e60 ffffffffa0348db4
 ffff88006eca8800 ffff88006eca8800 0000000000000000 ffffffffa0345b30
Call Trace:
 <IRQ> <0> [<ffffffffa0345b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0345850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa0348db4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa0345b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0345045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffff80217c56>] ? read_tsc+0x16/0x40
 [<ffffffffa0345b55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0> [<ffffffff80218afd>] ? mwait_idle+0x5d/0x70
 [<ffffffff8020fdd2>] ? enter_idle+0x22/0x30
 [<ffffffff8020fe2e>] ? cpu_idle+0x4e/0x80
 [<ffffffff804eb5cd>] ? rest_init+0x5d/0x70
Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 8d 54 07 1=
0 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <48> c7 47 =
30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff88006eca8a48
---[ end trace 62fd644f9e0af320 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..  =20
-------------------------------
Tue Sep  1 04:03:25 CEST 2009
-------------------------------
BUG: unable to handle kernel paging request at ffff88000ad0a248
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 206063 PMD 812067 PTE ad0a160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/class/vc/vcsa5/dev
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_al=
loc snd_mixer_oss snd soundcore i2c_viapro i2c_core sr_mod 8139too mii sh=
pchp pci_hotplug binfmt_misc ext3 jbd rtc_cmos floppy thermal button cpuf=
req_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_tab=
le processor via_agp evdev sg pata_via ata_generic ide_pci_generic pata_a=
cpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0018:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff88000ad0a000 RCX: 0000000000000058
RDX: ffffe200019d57a8 RSI: ffffffff8067f060 RDI: ffff88000ad0a218
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 000000000000050a
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff88000ad0a218
R13: ffff88000ad0a000 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000000000000(0000) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff88000ad0a248 CR3: 00000000751da000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8068c000, task ffffffff806323=
60)
Stack:
 ffff88000ad0a000 ffff88000ad0a000 ffff88000ad0a000 ffffffffa0350b30
 ffffffff80717e30 ffffffffa0350850 ffffffff80717e60 ffffffffa0353db4
 ffff88000ad0a000 ffff88000ad0a000 0000000000000000 ffffffffa0350b30
Call Trace:
 <IRQ> <0> [<ffffffffa0350b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0350850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa0353db4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa0350b30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa0350045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffffa0350b55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0> [<ffffffff80218afd>] ? mwait_idle+0x5d/0x70
 [<ffffffff8020fdd2>] ? enter_idle+0x22/0x30
 [<ffffffff8020fe2e>] ? cpu_idle+0x4e/0x80
 [<ffffffff804eb5cd>] ? rest_init+0x5d/0x70
Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 8d 54 07 1=
0 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <48> c7 47 =
30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff88000ad0a248
---[ end trace 8cace7d340707eda ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..  =20
-------------------------------
Wed Sep  2 04:03:25 CEST 2009
-------------------------------
  =20
-------------------------------
Thu Sep  3 04:03:19 CEST 2009
-------------------------------
  =20
-------------------------------
Fri Sep  4 04:03:21 CEST 2009
-------------------------------
BUG: unable to handle kernel paging request at ffff8800141b6a48
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 206063 PMD 85c067 PTE 141b6160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/class/vc/vcsa6/dev
CPU 0=20
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lo=
ckd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec =
ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_mi=
di_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_al=
loc snd_mixer_oss snd shpchp i2c_viapro 8139too pci_hotplug soundcore i2c=
_core sr_mod mii binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservati=
ve cpufreq_powersave acpi_cpufreq freq_table via_agp floppy sg rtc_cmos t=
hermal evdev processor button pata_via ata_generic ide_pci_generic pata_a=
cpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 32129, comm: setiathome-5.28 Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0000:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff8800141b6800 RCX: 0000000000000058
RDX: ffffe200004610c8 RSI: ffffffff8067f060 RDI: ffff8800141b6a18
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 00000000000001b6
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff8800141b6a18
R13: ffff8800141b6800 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000041ee4940(0063) GS:ffffffff80720000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff8800141b6a48 CR3: 00000000781d5000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process setiathome-5.28 (pid: 32129, threadinfo ffff8800781e2000, task ff=
ff8800183641a0)
Stack:
 ffff8800141b6800 ffff8800141b6800 ffff8800141b6800 ffffffffa034ab30
 ffffffff80717e30 ffffffffa034a850 ffffffff80717e60 ffffffffa034ddb4
 ffff8800141b6800 ffff8800141b6800 0000000000000000 ffffffffa034ab30
Call Trace:
 <IRQ> <0> [<ffffffffa034ab30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa034a850>] ax25_stop_heartbeat+0x10/0x20 [ax25]
 [<ffffffffa034ddb4>] ax25_destroy_socket+0x64/0x210 [ax25]
 [<ffffffffa034ab30>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa034a045>] ax25_std_heartbeat_expiry+0xf5/0x100 [ax25]
 [<ffffffff80217c56>] ? read_tsc+0x16/0x40
 [<ffffffffa034ab55>] ax25_heartbeat_expiry+0x25/0x60 [ax25]
 [<ffffffff8024976c>] run_timer_softirq+0x15c/0x230
 [<ffffffff8025f8ff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024506c>] __do_softirq+0x7c/0x110
 [<ffffffff8021271c>] call_softirq+0x1c/0x30
 [<ffffffff8021407d>] do_softirq+0x5d/0xa0
 [<ffffffff80244c95>] irq_exit+0x45/0x50
 [<ffffffff80223e85>] smp_apic_timer_interrupt+0x55/0x90
 [<ffffffff80212253>] apic_timer_interrupt+0x13/0x20
 <EOI> <0>Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 =
8d 54 07 10 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <=
48> c7 47 30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00=20
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff8800141b6a48
---[ end trace 469a474dc114bf10 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..  =20
-------------------------------
Sat Sep  5 04:03:26 CEST 2009
-------------------------------
  =20
-------------------------------
Sun Sep  6 04:03:11 CEST 2009
-------------------------------
  =20
-------------------------------
Mon Sep  7 04:03:20 CEST 2009
-------------------------------

--------------000109030607030706030307--
