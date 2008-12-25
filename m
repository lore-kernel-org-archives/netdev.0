From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Happy v2.6.28
Date: Thu, 25 Dec 2008 14:26:42 +0200
Message-ID: <84144f020812250426x255cc00esd33f0075292b486b@mail.gmail.com>
References: <bMLNZ-3QM-1@gated-at.bofh.it>
	 <200812250853.mBP8rxrr004080@server.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Hans Lambrechts" <hans.lambrechts@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:38724 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbYLYM0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 07:26:48 -0500
In-Reply-To: <200812250853.mBP8rxrr004080@server.home.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hans,

On Thu, Dec 25, 2008 at 10:53 AM, Hans Lambrechts
<hans.lambrechts@skynet.be> wrote:
> this message appears in the log when the sendmail daemon tries to start.
> This BUG appears in v2.6.28, -rc9 works fine.
>
> Dec 25 09:30:45 server kernel: BUG: unable to handle kernel paging request
> at 00442001
> Dec 25 09:30:45 server kernel: IP: [<c01706c4>] kmem_cache_alloc+0x51/0x8c
> Dec 25 09:30:45 server kernel: *pde = 00000000
> Dec 25 09:30:45 server kernel: Oops: 0000 [#4] PREEMPT SMP
> Dec 25 09:30:45 server kernel: last sysfs
> file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:02.0/local_cpus
> Dec 25 09:30:45 server kernel: Modules linked in: radeon drm snd_pcm_oss
> snd_mixer_oss snd_seq w83627hf hwmon_vid snd_seq_device iptable_filter
> ip_tables ip6table_filter ip6_tables x_tables ipv6 microcode tcp_cubic loop
> snd_intel8x0 ohci1394 snd_ac97_codec 8139cp 8139too ieee1394 ac97_bus
> snd_pcm snd_timer iTCO_wdt parport_pc rtc_cmos i2c_i801 snd mii
> iTCO_vendor_support shpchp sr_mod intel_agp rtc_core i2c_core parport
> soundcore agpgart pci_hotplug button rtc_lib cdrom snd_page_alloc sg
> dm_mirror dm_region_hash dm_log ehci_hcd uhci_hcd sd_mod crc_t10dif usbcore
> dm_snapshot dm_mod edd ext3 mbcache jbd fan ata_piix libata scsi_mod
> thermal processor [last unloaded: speedstep_lib]
> Dec 25 09:30:45 server kernel:
> Dec 25 09:30:45 server kernel: Pid: 5918, comm: sendmail Tainted: G      D
> (2.6.28 #60)
> Dec 25 09:30:45 server kernel: EIP: 0060:[<c01706c4>] EFLAGS: 00010002 CPU:
> 0
> Dec 25 09:30:45 server kernel: EIP is at kmem_cache_alloc+0x51/0x8c
> Dec 25 09:30:45 server kernel: EAX: 00000000 EBX: 00000282 ECX: 00442001
> EDX: c1c0a404
> Dec 25 09:30:45 server kernel: ESI: 00000504 EDI: 00442001 EBP: f6b076c0
> ESP: f438dec4
> Dec 25 09:30:45 server kernel:  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Dec 25 09:30:45 server kernel: Process sendmail (pid: 5918, ti=f438c000
> task=f42c8f00 task.ti=f438c000)
> Dec 25 09:30:45 server kernel: Stack:
> Dec 25 09:30:45 server kernel:  00442001 c0265f06 000080d0 c015c35f 000080d0
> f86d38b0 f86d38b0 f6b076c0
> Dec 25 09:30:45 server kernel:  c0265f06 0000000a f86d38b0 f86d38b0 0000000a
> 00000600 c026729c f86d38b0
> Dec 25 09:30:45 server kernel:  f86d39c8 ffffffa2 f869f77d f86d38b0 00000006
> f3826600 c046ee00 06000000
> Dec 25 09:30:45 server kernel: Call Trace:
> Dec 25 09:30:45 server kernel:  [<c0265f06>] sk_prot_alloc+0x1c/0xac
> Dec 25 09:30:45 server kernel:  [<c015c35f>] __inc_zone_state+0x10/0x61
> Dec 25 09:30:45 server kernel:  [<c0265f06>] sk_prot_alloc+0x1c/0xac
> Dec 25 09:30:45 server kernel:  [<c026729c>] sk_alloc+0x19/0x47
> Dec 25 09:30:45 server kernel:  [<f869f77d>] inet6_create+0x166/0x2f2 [ipv6]
> Dec 25 09:30:45 server kernel:  [<c02641e4>] __sock_create+0x169/0x245
> Dec 25 09:30:45 server kernel:  [<c02642fb>] sock_create+0x22/0x27
> Dec 25 09:30:45 server kernel:  [<c026450b>] sys_socket+0x2b/0x56
> Dec 25 09:30:45 server kernel:  [<c026507d>] sys_socketcall+0x6c/0x1a1
> Dec 25 09:30:45 server kernel:  [<c010391d>] sysenter_do_call+0x12/0x21
> Dec 25 09:30:45 server kernel: Code: 8b 72 10 85 c9 89 0c 24 75 1b 52 89 e8
> ff 74 24 08 83 c9 ff 8b 54 24 10 e8 37 f9 ff ff 89 44 24 08 5f 5d eb 0b 8b
> 3c 24 8b 42 0c <8b> 04 87 89 02 53 9d 66 83 7c 24 08 00 79 21 83 3c 24 00
> 74 1b
> Dec 25 09:30:45 server kernel: EIP: [<c01706c4>] kmem_cache_alloc+0x51/0x8c
> SS:ESP 0068:f438dec4
> Dec 25 09:30:45 server kernel: ---[ end trace 9ece963f58896a61 ]---

Looks like slab corruption. Can we have your .config, please? I'm
cc'ing netdev as the oops happens in kmem_cache_alloc() so the
networking code is a prime suspect of the corrupting kmem_cache_free()
call (although the bug might be elsewhere as well).

                        Pekka
