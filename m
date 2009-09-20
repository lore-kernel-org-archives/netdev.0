From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: Re: [AX25] kernel panic
Date: Sun, 20 Sep 2009 10:42:13 +0200
Message-ID: <4AB5EAE5.6070605@upmc.fr>
References: <4AA82BF0.7040203@upmc.fr> <20090910142436.GB10547@linux-mips.org> <4AA9288B.2070205@upmc.fr> <20090911120557.GA12175@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010300080201020708050206"
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090911120557.GA12175@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010300080201020708050206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Here are the first events noticed since I turned on 
CONFIG_DEBUG_OBJECTS_TIMERS option.

First a kernel BUG, second a kernel panic.

Best regards,

Bernard Pidoux






--------------010300080201020708050206
Content-Type: text/plain;
 name="kernel_bug"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel_bug"

------------[ cut here ]------------
kernel BUG at kernel/timer.c:913!
invalid opcode: 0000 [#1] 
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0 
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 binfmt_misc loop ext3 jbd cpufreq_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_table snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd soundcore shpchp pci_hotplug i2c_viapro i2c_core via_agp floppy 8139cp 8139too mii sg sr_mod processor rtc_cmos button thermal evdev pata_via ata_generic ide_pci_generic pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 24497, comm: astropulse_5.06 Not tainted 2.6.31-nosmp #3 MS-7258
RIP: 0010:[<ffffffff81061412>]  [<ffffffff81061412>] cascade+0xb2/0xc0
RSP: 0000:ffffffff8155be00  EFLAGS: 00010082
RAX: 0000000000000000 RBX: ffff880050c4c218 RCX: 0000000104445204
RDX: ffffffff8132b3d0 RSI: ffff880050c4c218 RDI: ffffffff81673540
RBP: ffffffff8155be40 R08: 0000000000000004 R09: ffffffff81568bc0
R10: ffffffff8155be28 R11: 0000000000000001 R12: ffffffff81673540
R13: ffffffff8155be00 R14: 0000000000000012 R15: 0000000000000001
FS:  00000000016e2860(0063) GS:ffffffff81558000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fe3eb15029c CR3: 000000007ecff000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
Process astropulse_5.06 (pid: 24497, threadinfo ffff88005807a000, task ffff880049588000)
Stack:
 ffff8800445748e0 ffff88007e86ab98 ffffffff8155be88 000000008c85481d
<0> 0000000000000000 ffffffff81673540 ffffffff8155be70 0000000000000081
<0> ffffffff8155bec0 ffffffff81061613 ffffffff81675150 ffffffff81674d50
Call Trace:
 <IRQ> 
 [<ffffffff81061613>] run_timer_softirq+0xf3/0x250
 [<ffffffff8102d0db>] ? lapic_next_event+0x2b/0x50
 [<ffffffff8107fc42>] ? clockevents_program_event+0x62/0xc0
 [<ffffffff8105b242>] __do_softirq+0xe2/0x1d0
 [<ffffffff8101414a>] call_softirq+0x1a/0x30
 [<ffffffff810162c5>] do_softirq+0x75/0xc0
 [<ffffffff8105ac45>] irq_exit+0x65/0x80
 [<ffffffff8102ddb5>] smp_apic_timer_interrupt+0x65/0xb0
 [<ffffffff81013c73>] apic_timer_interrupt+0x13/0x20
 <EOI> 
Code: 45 fe ff ff 4c 39 eb 48 8b 13 75 dd 48 8b 55 d8 65 48 33 14 25 28 00 00 00 44 89 f0 75 11 48 83 c4 20 5b 41 5c 41 5d 41 5e c9 c3 <0f> 0b eb fe e8 c5 29 ff ff 0f 1f 44 00 00 55 48 89 e5 48 83 ec 
RIP  [<ffffffff81061412>] cascade+0xb2/0xc0
 RSP <ffffffff8155be00>
---[ end trace 2efb8d4aaedbf503 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 24497, comm: astropulse_5.06 Tainted: G      D    2.6.31-nosmp #3
Call Trace:
 <IRQ>  [<ffffffff813d5e52>] panic+0xb2/0x180
 [<ffffffff8132f8ff>] ? __kfree_skb+0x6f/0xe0
 [<ffffffff810549bd>] ? console_unblank+0x8d/0xd0
 [<ffffffff812bdcee>] ? unblank_screen+0x1e/0x40
 [<ffffffff81053a36>] ? oops_exit+0x36/0x60
 [<ffffffff81017947>] oops_end+0xe7/0x100
 [<ffffffff810179bd>] ? oops_begin+0x5d/0x80
 [<ffffffff81017b52>] die+0x62/0xa0
 [<ffffffff81014e86>] do_trap+0x166/0x190
 [<ffffffff8107715d>] ? notify_die+0x3d/0x60
 [<ffffffff810153a5>] do_invalid_op+0xa5/0xd0
 [<ffffffff81061412>] ? cascade+0xb2/0xc0
 [<ffffffff8104dcde>] ? wake_up_state+0x1e/0x40
 [<ffffffff81013ddb>] invalid_op+0x1b/0x20
 [<ffffffff8132b3d0>] ? sock_def_write_space+0x0/0xb0
 [<ffffffff81061412>] ? cascade+0xb2/0xc0
 [<ffffffff81061613>] run_timer_softirq+0xf3/0x250
 [<ffffffff8102d0db>] ? lapic_next_event+0x2b/0x50
 [<ffffffff8107fc42>] ? clockevents_program_event+0x62/0xc0
 [<ffffffff8105b242>] __do_softirq+0xe2/0x1d0
 [<ffffffff8101414a>] call_softirq+0x1a/0x30
 [<ffffffff810162c5>] do_softirq+0x75/0xc0
 [<ffffffff8105ac45>] irq_exit+0x65/0x80
 [<ffffffff8102ddb5>] smp_apic_timer_interrupt+0x65/0xb0
 [<ffffffff81013c73>] apic_timer_interrupt+0x13/0x20
 <EOI> 
Rebooting in 60 seconds..[root@f6bvp-9 bernard]# 


--------------010300080201020708050206--
