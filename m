From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: kernel BUG at kernel/timer.c:951!
Date: Sat, 19 Dec 2009 14:38:58 +0100
Message-ID: <4B2CD772.1030106@upmc.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080605090600070801000403"
To: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bernard Pidoux <bpidoux@free.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752282AbZLSNjV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080605090600070801000403
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

I am experiencing a few kernel panics on my Linux system using 2.6.32 and 2.6.32.1 kernels
with nosmp.

Linux f6bvp-11 2.6.32.1-nosmp #4 Tue Dec 15 23:13:28 CET 2009 x86_64 Intel(R) Core(TM)2 Duo CPU     E4500  @ 2.20GHz GNU/Linux
 
Gnu C                  4.3.2
Gnu make               3.81
binutils               2.19.51.0.2.20090204
util-linux             2.14.1
mount                  support
module-init-tools      3.6
e2fsprogs              1.41.4
PPP                    2.4.4
Linux C Library        2.9
Dynamic linker (ldd)   2.9
Procps                 3.2.7
Net-tools              1.60
Kbd                    1.15
Sh-utils               7.1
Modules Loaded         netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 binfmt_misc loop ext3 jbd snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd i2c_viapro 8139cp i2c_core floppy sg sr_mod shpchp 8139too rtc_cmos soundcore pci_hotplug button via_agp mii evdev pata_via ata_generic ide_pci_generic sata_via libata sd_mod scsi_mod crc_t10dif

The last kernel panic is reporting a kernel BUG at kernel/timer.c:951!

Bernard Pidoux

 

--------------080605090600070801000403
Content-Type: text/plain;
 name="nc_u_l_p_6666"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nc_u_l_p_6666"

-------------------------------
general protection fault: 0000 [#1] 
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0 
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd soundcore shpchp 8139cp 8139too pci_hotplug sr_mod i2c_viapro i2c_core mii ipv6 binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_table rtc_cmos floppy processor thermal via_agp button evdev sg pata_via ata_generic ide_pci_generic pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.32-nosmp #1 MS-7258
RIP: 0010:[<ffffffff81057c16>]  [<ffffffff81057c16>] run_timer_softirq+0x176/0x300
RSP: 0018:ffffffff814fbe70  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880049c6f040 RCX: 1bc0000000000000
RDX: ffffffff814fbeb0 RSI: 3a75ffe60e489c6f RDI: ffff880049c6f000
RBP: ffffffff814fbef0 R08: de00000000000000 R09: ffff880049c6f040
R10: ffffffff81506e60 R11: 0000000000000000 R12: ffffffff81610268
R13: ffffffff816104c0 R14: ffffffff814fbeb0 R15: ff0000fb001001f0
FS:  0000000000000000(0000) GS:ffffffff814f8000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f34976aa000 CR3: 000000002cbd4000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff814da000, task ffffffff814ece40)
Stack:
 ffffffff814dbfd8 ffffffff814dbfd8 00000100810178c6 ffff880049c6f000
<0> ffffffff816120d8 ffffffff81611cd8 ffffffff816118d8 ffffffff816114d8
<0> ffffffff814fbeb0 ffffffff814fbeb0 ffffffff81027d98 ffffffff814dbfd8
Call Trace:
 <IRQ> 
 [<ffffffff81027d98>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104f642>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e0a>] call_softirq+0x1a/0x30
 [<ffffffff81013b55>] do_softirq+0x65/0xa0
 [<ffffffff8104f22d>] irq_exit+0x3d/0x50
 [<ffffffff81028869>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011933>] apic_timer_interrupt+0x13/0x20
 <EOI> 
 [<ffffffff81018880>] ? mwait_idle+0x80/0xc0
 [<ffffffff81068851>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff8101012c>] ? cpu_idle+0x8c/0xb0
 [<ffffffff8135cfcb>] ? rest_init+0x5b/0x70
 [<ffffffff8155bc9d>] ? start_kernel+0x3a6/0x46f
 [<ffffffff8155b2b9>] ? x86_64_start_reservations+0x99/0xb9
 [<ffffffff8155b3df>] ? x86_64_start_kernel+0x106/0x121
 [<ffffffff8155b140>] ? early_idt_handler+0x0/0x71
Code: 4c 8b 25 4e 62 4f 00 4d 85 e4 74 1b 49 8b 04 24 0f 1f 44 00 00 49 83 c4 08 48 89 df ff d0 49 8b 04 24 48 85 c0 75 ee 48 8b 7d 98 <41> ff d7 8b 05 49 62 4f 00 85 c0 74 27 4c 8b 25 56 62 4f 00 4d 
RIP  [<ffffffff81057c16>] run_timer_softirq+0x176/0x300
 RSP <ffffffff814fbe70>
---[ end trace b7400eefcee63331 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D    2.6.32-nosmp #1
Call Trace:
 <IRQ>  [<ffffffff813640ab>] panic+0xa0/0x172
 [<ffffffff812cf8c2>] ? __kfree_skb+0x42/0xb0
 [<ffffffff810117d3>] ? ret_from_intr+0x0/0x10
 [<ffffffff812cf8c2>] ? __kfree_skb+0x42/0xb0
 [<ffffffff81014ea5>] ? oops_end+0xc5/0xe0
 [<ffffffff81014eac>] oops_end+0xcc/0xe0
 [<ffffffff81015076>] die+0x56/0x90
 [<ffffffff81013138>] do_general_protection+0x158/0x160
 [<ffffffff81366665>] general_protection+0x25/0x30
 [<ffffffff81057c16>] ? run_timer_softirq+0x176/0x300
 [<ffffffff81027d98>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104f642>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e0a>] call_softirq+0x1a/0x30
 [<ffffffff81013b55>] do_softirq+0x65/0xa0
 [<ffffffff8104f22d>] irq_exit+0x3d/0x50
 [<ffffffff81028869>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011933>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff81018880>] ? mwait_idle+0x80/0xc0
 [<ffffffff81068851>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff8101012c>] ? cpu_idle+0x8c/0xb0
 [<ffffffff8135cfcb>] ? rest_init+0x5b/0x70
 [<ffffffff8155bc9d>] ? start_kernel+0x3a6/0x46f
 [<ffffffff8155b2b9>] ? x86_64_start_reservations+0x99/0xb9
 [<ffffffff8155b3df>] ? x86_64_start_kernel+0x106/0x121
 [<ffffffff8155b140>] ? early_idt_handler+0x0/0x71
Rebooting in 60 seconds..  
-------------------------------
-------------------------------
BUG: unable to handle kernel paging request at 00000000000075d0
IP: [<00000000000075d0>] 0x75d0
PGD 67cf2067 PUD 78b65067 PMD 0 
Thread overran stack, or stack corrupted
Oops: 0000 [#1] 
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0 
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd 8139cp i2c_viapro 8139too shpchp soundcore i2c_core pci_hotplug mii sr_mod binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_table floppy rtc_cmos processor via_agp button thermal evdev sg pata_via ata_generic ide_pci_generic pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.32-nosmp #1 MS-7258
RIP: 0010:[<00000000000075d0>]  [<00000000000075d0>] 0x75d0
RSP: 0018:ffffffff814fbe68  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880003842618 RCX: 1080000000000000
RDX: ffff8800666ba910 RSI: 0a9dfff79ef83842 RDI: 0000000000000000
RBP: ffffffff814fbef0 R08: 8400000000000000 R09: ffff880003842618
R10: ffffffff81506e60 R11: 0000000000000000 R12: ffffffff81610268
R13: ffffffff816104c0 R14: ffffffff814fbeb0 R15: 00000000000075d0
FS:  0000000000000000(0000) GS:ffffffff814f8000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000075d0 CR3: 0000000067cce000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff814da000, task ffffffff814ece40)
Stack:
 ffffffff81057c19 ffffffff814dbfd8 ffffffff814dbfd8 00000100810178c6
<0> 0000000000000000 ffffffff816120d8 ffffffff81611cd8 ffffffff816118d8
<0> ffffffff816114d8 ffff8800666ba910 ffff8800666ba910 ffffffff81027d98
Call Trace:
 <IRQ> 
 [<ffffffff81057c19>] ? run_timer_softirq+0x179/0x300
 [<ffffffff81027d98>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104f642>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e0a>] call_softirq+0x1a/0x30
 [<ffffffff81013b55>] do_softirq+0x65/0xa0
 [<ffffffff8104f22d>] irq_exit+0x3d/0x50
 [<ffffffff81028869>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011933>] apic_timer_interrupt+0x13/0x20
 <EOI> 
 [<ffffffff81018880>] ? mwait_idle+0x80/0xc0
 [<ffffffff81068851>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff8101012c>] ? cpu_idle+0x8c/0xb0
 [<ffffffff8135cfcb>] ? rest_init+0x5b/0x70
 [<ffffffff8155bc9d>] ? start_kernel+0x3a6/0x46f
 [<ffffffff8155b2b9>] ? x86_64_start_reservations+0x99/0xb9
 [<ffffffff8155b3df>] ? x86_64_start_kernel+0x106/0x121
 [<ffffffff8155b140>] ? early_idt_handler+0x0/0x71
Code:  Bad RIP value.
RIP  [<00000000000075d0>] 0x75d0
 RSP <ffffffff814fbe68>
CR2: 00000000000075d0
---[ end trace 1d821a4ff312041a ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D    2.6.32-nosmp #1
Call Trace:
 <IRQ>  [<ffffffff813640ab>] panic+0xa0/0x172
 [<ffffffff812cf8c2>] ? __kfree_skb+0x42/0xb0
 [<ffffffff810117d3>] ? ret_from_intr+0x0/0x10
 [<ffffffff81014e3a>] ? oops_end+0x5a/0xe0
 [<ffffffff81014eac>] oops_end+0xcc/0xe0
 [<ffffffff81030c08>] no_context+0xe8/0x260
 [<ffffffff812cf9d4>] ? kfree_skb+0x64/0x90
 [<ffffffff81030eb5>] __bad_area_nosemaphore+0x135/0x200
 [<ffffffff81045df6>] ? enqueue_task_fair+0x186/0x3a0
 [<ffffffff8103a791>] ? activate_task+0x51/0x80
 [<ffffffff81030f8e>] bad_area_nosemaphore+0xe/0x10
 [<ffffffff8103138e>] do_page_fault+0x23e/0x2f0
 [<ffffffff81366695>] page_fault+0x25/0x30
 [<ffffffff81057c19>] ? run_timer_softirq+0x179/0x300
 [<ffffffff81027d98>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104f642>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e0a>] call_softirq+0x1a/0x30
 [<ffffffff81013b55>] do_softirq+0x65/0xa0
 [<ffffffff8104f22d>] irq_exit+0x3d/0x50
 [<ffffffff81028869>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011933>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff81018880>] ? mwait_idle+0x80/0xc0
 [<ffffffff81068851>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff8101012c>] ? cpu_idle+0x8c/0xb0
 [<ffffffff8135cfcb>] ? rest_init+0x5b/0x70
 [<ffffffff8155bc9d>] ? start_kernel+0x3a6/0x46f
 [<ffffffff8155b2b9>] ? x86_64_start_reservations+0x99/0xb9
 [<ffffffff8155b3df>] ? x86_64_start_kernel+0x106/0x121
 [<ffffffff8155b140>] ? early_idt_handler+0x0/0x71
Rebooting in 60 seconds..   
-------------------------------
-------------------------------
BUG: unable to handle kernel NULL pointer dereference at 0000000000000268
IP: [<ffffffff810ceb11>] bdi_register+0x31/0x190
PGD d563067 PUD d417067 PMD 0 
Oops: 0000 [#1] 
last sysfs file: /sys/devices/pci0000:00/0000:00:00.0/modalias
CPU 0 
Modules linked in: loop(+) netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss 8139cp 8139too snd shpchp rtc_cmos i2c_viapro soundcore pci_hotplug i2c_core mii sr_mod binfmt_misc ext3 jbd via_agp evdev sg pata_via ata_generic ide_pci_generic sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 28774, comm: modprobe Tainted: G        W  2.6.32-nosmp #2 MS-7258
RIP: 0010:[<ffffffff810ceb11>]  [<ffffffff810ceb11>] bdi_register+0x31/0x190
RSP: 0018:ffff88000c6e3da8  EFLAGS: 00010282
RAX: 0000000000000000 RBX: 0000000000000140 RCX: 0000000000000007
RDX: ffffffff81401845 RSI: 0000000000000000 RDI: 0000000000000140
RBP: ffff88000c6e3e98 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000000000010 R11: 0000000000000000 R12: ffff880061659000
R13: 0000000000100000 R14: 0000000000ce41b0 R15: 0000000000cdc388
FS:  00002ac71c305f90(0000) GS:ffffffff8148e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000268 CR3: 000000001da23000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 28774, threadinfo ffff88000c6e2000, task ffff88007ece2d20)
Stack:
 ffff88000c6e3dc8 0000000000000002 ffff88000c6e3e28 ffffffff8142d76c
<0> 0000000000000000 0000000000cdc388 ffff88000c6e3de8 0000000000000007
<0> 0000000000000000 0000000000000001 ffffffff814876a7 ffffffff81076c4f
Call Trace:
 [<ffffffff81076c4f>] ? print_modules+0x5f/0xc0
 [<ffffffff811caa8a>] ? blk_register_queue+0xea/0xf0
 [<ffffffff811caa8a>] ? blk_register_queue+0xea/0xf0
 [<ffffffff810476dc>] ? warn_slowpath_common+0x9c/0xd0
 [<ffffffff8104771f>] ? warn_slowpath_null+0xf/0x20
 [<ffffffff811caa8a>] ? blk_register_queue+0xea/0xf0
 [<ffffffff810cec93>] bdi_register_dev+0x23/0x30
 [<ffffffff811cf761>] add_disk+0x121/0x160
 [<ffffffffa00af834>] ? loop_alloc+0x144/0x180 [loop]
 [<ffffffffa00a0185>] loop_init+0x185/0x1e2 [loop]
 [<ffffffffa00a0000>] ? loop_init+0x0/0x1e2 [loop]
 [<ffffffff8100a037>] do_one_initcall+0x37/0x1a0
 [<ffffffff8107aba0>] sys_init_module+0xe0/0x260
 [<ffffffff81010e7f>] system_call_fastpath+0x16/0x1b
Code: 48 81 ec f0 00 00 00 48 89 5d e8 4c 89 65 f0 48 89 fb 4c 89 6d f8 48 89 8d 48 ff ff ff 4c 89 85 50 ff ff ff 4c 89 8d 58 ff ff ff <48> 83 bf 28 01 00 00 00 74 15 48 8b 5d e8 4c 8b 65 f0 4c 8b 6d 
RIP  [<ffffffff810ceb11>] bdi_register+0x31/0x190
 RSP <ffff88000c6e3da8>
CR2: 0000000000000268
---[ end trace f6be10bc0c089fe3 ]---
Kernel panic - not syncing: Fatal exception
Pid: 28774, comm: modprobe Tainted: G      D W  2.6.32-nosmp #2
Call Trace:
 [<ffffffff8132246b>] panic+0xa0/0x172
 [<ffffffff8107cac4>] ? crash_kexec+0x74/0x100
 [<ffffffff8128e572>] ? __kfree_skb+0x42/0xb0
 [<ffffffff8101192e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff81014e3a>] ? oops_end+0x5a/0xe0
 [<ffffffff81014e77>] oops_end+0x97/0xe0
 [<ffffffff8102f458>] no_context+0xe8/0x260
 [<ffffffff8102f705>] __bad_area_nosemaphore+0x135/0x200
 [<ffffffff811e38f7>] ? vsnprintf+0x217/0x600
 [<ffffffff8102f828>] bad_area+0x48/0x60
 [<ffffffff8102fc3c>] do_page_fault+0x29c/0x2f0
 [<ffffffff81324a55>] page_fault+0x25/0x30
 [<ffffffff810ceb11>] ? bdi_register+0x31/0x190
 [<ffffffff81076c4f>] ? print_modules+0x5f/0xc0
 [<ffffffff811caa8a>] ? blk_register_queue+0xea/0xf0
 [<ffffffff811caa8a>] ? blk_register_queue+0xea/0xf0
 [<ffffffff810476dc>] ? warn_slowpath_common+0x9c/0xd0
 [<ffffffff8104771f>] ? warn_slowpath_null+0xf/0x20
 [<ffffffff811caa8a>] ? blk_register_queue+0xea/0xf0
 [<ffffffff810cec93>] bdi_register_dev+0x23/0x30
 [<ffffffff811cf761>] add_disk+0x121/0x160
 [<ffffffffa00af834>] ? loop_alloc+0x144/0x180 [loop]
 [<ffffffffa00a0185>] loop_init+0x185/0x1e2 [loop]
 [<ffffffffa00a0000>] ? loop_init+0x0/0x1e2 [loop]
 [<ffffffff8100a037>] do_one_initcall+0x37/0x1a0
 [<ffffffff8107aba0>] sys_init_module+0xe0/0x260
 [<ffffffff81010e7f>] system_call_fastpath+0x16/0x1b
Rebooting in 60 seconds..   
-------------------------------
-------------------------------
general protection fault: 0000 [#1] 
last sysfs file: /sys/devices/pci0000:00/0000:00:0f.1/host3/target3:0:1/3:0:1:0/model
CPU 0 
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 binfmt_misc loop ext3 jbd snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd i2c_viapro 8139cp soundcore i2c_core floppy sr_mod sg shpchp pci_hotplug 8139too mii via_agp rtc_cmos button evdev pata_via ata_generic ide_pci_generic sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.32.1-nosmp #4 MS-7258
RIP: 0010:[<ffffffffa028fe4d>]  [<ffffffffa028fe4d>] ax25_heartbeat_expiry+0xd/0x60 [ax25]
RSP: 0018:ffffffff814fbe60  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff880059831a18 RCX: 0c40000000000000
RDX: ac846c8cff811900 RSI: 08e5ffe21f419831 RDI: ffff880059831800
RBP: ffffffff814fbe60 R08: 6200000000000000 R09: ffff880059831a18
R10: ffffffff81506dc0 R11: 0000000000000000 R12: ffffffff81607128
R13: ffffffff81607380 R14: ffffffff814fbeb0 R15: ffffffffa028fe40
FS:  0000000000000000(0000) GS:ffffffff814f8000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f156815c000 CR3: 00000000637e2000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff814da000, task ffffffff814ece40)
Stack:
 ffffffff814fbef0 ffffffff810574d9 ffffffff814dbfd8 ffffffff814dbfd8
<0> 0000010081017906 ffff880059831800 ffffffff81608f98 ffffffff81608b98
<0> ffffffff81608798 ffffffff81608398 ffffffff814fbeb0 ffffffff814fbeb0
Call Trace:
 <IRQ> 
 [<ffffffff810574d9>] run_timer_softirq+0x179/0x300
 [<ffffffff81027c08>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104ef02>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e4a>] call_softirq+0x1a/0x30
 [<ffffffff81013b95>] do_softirq+0x65/0xa0
 [<ffffffff8104eaed>] irq_exit+0x3d/0x50
 [<ffffffff810286d9>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011973>] apic_timer_interrupt+0x13/0x20
 <EOI> 
 [<ffffffff81018720>] ? mwait_idle+0x80/0xc0
 [<ffffffff81068101>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff8101012c>] ? cpu_idle+0x8c/0xb0
 [<ffffffff813597fb>] ? rest_init+0x5b/0x70
 [<ffffffff8155ac8d>] ? start_kernel+0x396/0x45f
 [<ffffffff8155a2b9>] ? x86_64_start_reservations+0x99/0xb9
 [<ffffffff8155a3df>] ? x86_64_start_kernel+0x106/0x121
 [<ffffffff8155a140>] ? early_idt_handler+0x0/0x71
Code: 80 7a 58 00 66 90 74 da c9 0f 1f 44 00 00 c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8b 57 28 48 89 e5 48 85 d2 74 0c <8b> 42 50 85 c0 78 11 83 f8 01 7f 17 0f 1f 80 00 00 00 00 e8 cb 
RIP  [<ffffffffa028fe4d>] ax25_heartbeat_expiry+0xd/0x60 [ax25]
 RSP <ffffffff814fbe60>
---[ end trace 44c0364064d76fee ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D    2.6.32.1-nosmp #4
Call Trace:
 <IRQ>  [<ffffffff8136086b>] panic+0xa0/0x172
 [<ffffffff812cc0f2>] ? __kfree_skb+0x42/0xb0
 [<ffffffff81011813>] ? ret_from_intr+0x0/0x10
 [<ffffffff81014e7a>] ? oops_end+0x5a/0xe0
 [<ffffffff81014eec>] oops_end+0xcc/0xe0
 [<ffffffff810150b6>] die+0x56/0x90
 [<ffffffff81013178>] do_general_protection+0x158/0x160
 [<ffffffff81362e25>] general_protection+0x25/0x30
 [<ffffffffa028fe40>] ? ax25_heartbeat_expiry+0x0/0x60 [ax25]
 [<ffffffffa028fe4d>] ? ax25_heartbeat_expiry+0xd/0x60 [ax25]
 [<ffffffff810574d9>] run_timer_softirq+0x179/0x300
 [<ffffffff81027c08>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104ef02>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e4a>] call_softirq+0x1a/0x30
 [<ffffffff81013b95>] do_softirq+0x65/0xa0
 [<ffffffff8104eaed>] irq_exit+0x3d/0x50
 [<ffffffff810286d9>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011973>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff81018720>] ? mwait_idle+0x80/0xc0
 [<ffffffff81068101>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff8101012c>] ? cpu_idle+0x8c/0xb0
 [<ffffffff813597fb>] ? rest_init+0x5b/0x70
 [<ffffffff8155ac8d>] ? start_kernel+0x396/0x45f
 [<ffffffff8155a2b9>] ? x86_64_start_reservations+0x99/0xb9
 [<ffffffff8155a3df>] ? x86_64_start_kernel+0x106/0x121
 [<ffffffff8155a140>] ? early_idt_handler+0x0/0x71
Rebooting in 60 seconds..   
-------------------------------
------------[ cut here ]------------
kernel BUG at kernel/timer.c:951!
invalid opcode: 0000 [#1] 
last sysfs file: /sys/devices/pci0000:00/0000:00:00.0/modalias
CPU 0 
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 binfmt_misc loop ext3 jbd snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd 8139cp i2c_viapro i2c_core 8139too soundcore floppy sr_mod via_agp shpchp pci_hotplug mii sg rtc_cmos button evdev pata_via ata_generic ide_pci_generic sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 25429, comm: setiathome-5.28 Not tainted 2.6.32.1-nosmp #4 MS-7258
RIP: 0010:[<ffffffff810538cb>]  [<ffffffff810538cb>] cascade+0x9b/0xa0
RSP: 0000:ffffffff814fbe30  EFLAGS: 00010082
RAX: 0000000000000000 RBX: ffff88005e5b6618 RCX: 0000000100c05204
RDX: ffffffff814fbe30 RSI: ffff88005e5b6618 RDI: ffffffff81607380
RBP: ffffffff814fbe60 R08: 0000000000000004 R09: ffffffff815090a0
R10: 0000000000000001 R11: 0000000000000000 R12: ffffffff81607380
R13: ffffffff814fbe30 R14: 0000000000000012 R15: 0000000000000001
FS:  00000000422f4940(0063) GS:ffffffff814f8000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f448ac9a000 CR3: 00000000525aa000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process setiathome-5.28 (pid: 25429, threadinfo ffff880074ed0000, task ffff8800525b2d20)
Stack:
 ffff880074c75970 ffff88005e5b6618 0000000000000000 ffffffff81607128
<0> ffffffff81607380 ffffffff814fbeb0 ffffffff814fbef0 ffffffff81057455
<0> ffff880074ed1fd8 ffff880074ed1fd8 ffffffff81017906 ffffffff814f4fa0
Call Trace:
 <IRQ> 
 [<ffffffff81057455>] run_timer_softirq+0xf5/0x300
 [<ffffffff81017906>] ? read_tsc+0x16/0x40
 [<ffffffff81027c08>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104ef02>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e4a>] call_softirq+0x1a/0x30
 [<ffffffff81013b95>] do_softirq+0x65/0xa0
 [<ffffffff8104eaed>] irq_exit+0x3d/0x50
 [<ffffffff810286d9>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011973>] apic_timer_interrupt+0x13/0x20
 <EOI> 
Code: 83 e0 fe 49 39 c4 75 23 48 89 d3 4c 89 e7 e8 7d fe ff ff 4c 39 eb 48 8b 13 75 dd 48 83 c4 10 44 89 f0 5b 41 5c 41 5d 41 5e c9 c3 <0f> 0b eb fe 90 55 48 8b 04 25 40 70 4f 81 48 8b 80 20 04 00 00 
RIP  [<ffffffff810538cb>] cascade+0x9b/0xa0
 RSP <ffffffff814fbe30>
---[ end trace 5feab457f7d8d266 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 25429, comm: setiathome-5.28 Tainted: G      D    2.6.32.1-nosmp #4
Call Trace:
 <IRQ>  [<ffffffff8136086b>] panic+0xa0/0x172
 [<ffffffff8107ec14>] ? crash_kexec+0x74/0x100
 [<ffffffff812cc0f2>] ? __kfree_skb+0x42/0xb0
 [<ffffffff810491d5>] ? console_unblank+0x75/0x90
 [<ffffffff81014eec>] oops_end+0xcc/0xe0
 [<ffffffff810150b6>] die+0x56/0x90
 [<ffffffff810129b6>] do_trap+0x146/0x170
 [<ffffffff81068101>] ? atomic_notifier_call_chain+0x11/0x20
 [<ffffffff81012e30>] do_invalid_op+0x90/0xb0
 [<ffffffff810538cb>] ? cascade+0x9b/0xa0
 [<ffffffffa0279f1d>] ? ax25_kiss_rcv+0x1ed/0x900 [ax25]
 [<ffffffff81011adb>] invalid_op+0x1b/0x20
 [<ffffffff810538cb>] ? cascade+0x9b/0xa0
 [<ffffffff81057455>] run_timer_softirq+0xf5/0x300
 [<ffffffff81017906>] ? read_tsc+0x16/0x40
 [<ffffffff81027c08>] ? lapic_next_event+0x18/0x20
 [<ffffffff8104ef02>] __do_softirq+0xd2/0x1b0
 [<ffffffff81011e4a>] call_softirq+0x1a/0x30
 [<ffffffff81013b95>] do_softirq+0x65/0xa0
 [<ffffffff8104eaed>] irq_exit+0x3d/0x50
 [<ffffffff810286d9>] smp_apic_timer_interrupt+0x59/0x90
 [<ffffffff81011973>] apic_timer_interrupt+0x13/0x20
 <EOI> 
Rebooting in 60 seconds..   
-------------------------------

--------------080605090600070801000403--
