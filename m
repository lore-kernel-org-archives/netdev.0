From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: swapper Not tainted 2.6.29.6
Date: Tue, 11 Aug 2009 12:23:40 +0200
Message-ID: <4A8146AC.4010104@free.fr>
References: <1237486732.30285.18.camel@f6bvp-11> <20090321.133428.05663162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050408040200060106070109"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-hams <linux-hams@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:52738 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbZHKMTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 08:19:34 -0400
In-Reply-To: <20090321.133428.05663162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050408040200060106070109
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Running kernel 2.6.29.6 compiled without SMP option there was a kernel panic.
I don't know if it is related to  /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
or to AX25 module or a configuration problem.

Here is the netconsole capture.




--------------050408040200060106070109
Content-Type: text/plain;
 name="nc_u_l_p_6666"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nc_u_l_p_6666"

BUG: unable to handle kernel paging request at ffff880004c90648
IP: [<ffffffff80249451>] del_timer+0x11/0xb0
PGD 202063 PUD 206063 PMD 7e2067 PTE 4c90160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
CPU 0 
Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm i2c_viapro snd_timer snd_page_alloc snd_mixer_oss snd i2c_core soundcore sr_mod 8139cp 8139too mii shpchp pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_table floppy sg rtc_cmos thermal via_agp processor evdev button pata_via ata_generic ide_pci_generic pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Pid: 0, comm: swapper Not tainted 2.6.29.6-nosmp #8 MS-7258
RIP: 0010:[<ffffffff80249451>]  [<ffffffff80249451>] del_timer+0x11/0xb0
RSP: 0018:ffffffff80717e00  EFLAGS: 00010246
RAX: ffffffff8067f0b8 RBX: ffff880004c90400 RCX: 0000000000000058
RDX: ffffe200009cb3d8 RSI: ffffffff8067f060 RDI: ffff880004c90618
RBP: ffffffff80717e20 R08: 0000000000000001 R09: 0000000000000490
R10: 0000000000000002 R11: ffffffff8067f008 R12: ffff880004c90618
R13: ffff880004c90400 R14: 0000000000000000 R15: ffffffff80717ed0
FS:  0000000000000000(0000) GS:ffffffff80720000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff880004c90648 CR3: 0000000074843000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8068c000, task ffffffff80632360)
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
Code: 10 18 00 00 eb a6 0f 1f 40 00 48 0f b6 c2 48 c1 e0 04 48 8d 54 07 10 eb 93 90 55 48 89 e5 41 56 45 31 f6 41 55 41 54 49 89 fc 53 <48> c7 47 30 00 00 00 00 48 83 3f 00 75 16 eb 76 0f 1f 80 00 00 
RIP  [<ffffffff80249451>] del_timer+0x11/0xb0
 RSP <ffffffff80717e00>
CR2: ffff880004c90648
---[ end trace 366e8cf762bbf316 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 60 seconds..

--------------050408040200060106070109--
