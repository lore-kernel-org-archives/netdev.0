From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.33 problems
Date: Tue, 2 Mar 2010 13:50:32 -0800
Message-ID: <20100302135032.e3d11bbf.akpm@linux-foundation.org>
References: <1267290551.13148@guyane.dyn-o-saur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org
To: werner@guyane.dyn-o-saur.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35162 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752834Ab0CBVum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 16:50:42 -0500
In-Reply-To: <1267290551.13148@guyane.dyn-o-saur.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Feb 2010 14:09:11 -0300 (GFT)
werner@guyane.dyn-o-saur.com wrote:

> For better error searching / correction, I add below the whole syslog.
> 
> This is refered to 2.6.33  published (without patchs)
> 
> This are different errors.
> 
> The most of them exists since 2.6.33-rc1 or appr. -rc5.
> 
> I posted here already the whole syslog.bz2 but nobody toke care.
> 
> the boot_vga error occurs only after I start the grafics mode.  It's the mainboard's embedded nvidia grafics. I use the vesa framebuffer driver of X 1.8
> 
> the int6_init error occurs also in text mode. I think it have something to do with internet.
> 
> Also the printk errors occur only when start the computer in the grafics mode, but not when starting it in the text mode.
> 
> Below is also the kernel config. Its the same like since -rc7 (but the errors are also the same)
> 
> 

Thanks.

>
> ...
>
> Feb 27 13:43:07 werner kernel: PERCPU: allocation failed, size=2048 align=8, failed to allocate new chunk
> Feb 27 13:43:07 werner kernel: Pid: 5314, comm: modprobe Tainted: G         C 2.6.33 #1
> Feb 27 13:43:07 werner kernel: Call Trace:
> Feb 27 13:43:07 werner kernel:  [<c1c682ca>] ? printk+0x14/0x16
> Feb 27 13:43:07 werner kernel:  [<c10bdfa3>] pcpu_alloc+0x6ba/0x73b
> Feb 27 13:43:07 werner kernel:  [<c10bb0be>] ? get_slab+0x8/0x50
> Feb 27 13:43:07 werner kernel:  [<c1b7283d>] ? neigh_parms_alloc+0x55/0xd1
> Feb 27 13:43:07 werner kernel:  [<c10be047>] __alloc_percpu+0xf/0x14
> Feb 27 13:43:07 werner kernel:  [<c1bb26cb>] snmp_mib_init+0x22/0x5a
> Feb 27 13:43:07 werner kernel:  [<fed105af>] ipv6_add_dev+0x191/0x30b [ipv6]
> Feb 27 13:43:07 werner kernel:  [<fd269000>] ? inet6_init+0x0/0x2a2 [ipv6]
> Feb 27 13:43:07 werner kernel:  [<fd2692ec>] addrconf_init+0x3b/0x11b [ipv6]
> Feb 27 13:43:07 werner kernel:  [<fd269195>] inet6_init+0x195/0x2a2 [ipv6]
> Feb 27 13:43:07 werner kernel:  [<c1001143>] do_one_initcall+0x51/0x13f
> Feb 27 13:43:07 werner kernel:  [<c1066570>] sys_init_module+0xac/0x1e0
> Feb 27 13:43:07 werner kernel:  [<c1c6acec>] syscall_call+0x7/0xb
> Feb 27 13:43:19 werner kdm_greet[5382]: Can't open default user face
> Feb 27 13:44:24 werner kernel: PERCPU: allocation failed, size=2048 align=8, failed to allocate new chunk
> Feb 27 13:44:24 werner kernel: Pid: 5737, comm: modprobe Tainted: G         C 2.6.33 #1
> Feb 27 13:44:24 werner kernel: Call Trace:
> Feb 27 13:44:24 werner kernel:  [<c1c682ca>] ? printk+0x14/0x16
> Feb 27 13:44:24 werner kernel:  [<c10bdfa3>] pcpu_alloc+0x6ba/0x73b
> Feb 27 13:44:24 werner kernel:  [<c10bb0be>] ? get_slab+0x8/0x50
> Feb 27 13:44:24 werner kernel:  [<c1b7283d>] ? neigh_parms_alloc+0x55/0xd1
> Feb 27 13:44:24 werner kernel:  [<c10be047>] __alloc_percpu+0xf/0x14
> Feb 27 13:44:24 werner kernel:  [<c1bb26cb>] snmp_mib_init+0x22/0x5a
> Feb 27 13:44:24 werner kernel:  [<fed105af>] ipv6_add_dev+0x191/0x30b [ipv6]
> Feb 27 13:44:24 werner kernel:  [<f91bf000>] ? inet6_init+0x0/0x2a2 [ipv6]
> Feb 27 13:44:24 werner kernel:  [<f91bf2ec>] addrconf_init+0x3b/0x11b [ipv6]
> Feb 27 13:44:24 werner kernel:  [<f91bf195>] inet6_init+0x195/0x2a2 [ipv6]
> Feb 27 13:44:24 werner kernel:  [<c1001143>] do_one_initcall+0x51/0x13f
> Feb 27 13:44:24 werner kernel:  [<c1066570>] sys_init_module+0xac/0x1e0
> Feb 27 13:44:24 werner kernel:  [<c1c6acec>] syscall_call+0x7/0xb
> Feb 27 13:44:27 werner kernel: PERCPU: allocation failed, size=2048 align=8, failed to allocate new chunk
> Feb 27 13:44:27 werner kernel: Pid: 5772, comm: modprobe Tainted: G         C 2.6.33 #1
> Feb 27 13:44:27 werner kernel: Call Trace:
> Feb 27 13:44:27 werner kernel:  [<c1c682ca>] ? printk+0x14/0x16
> Feb 27 13:44:27 werner kernel:  [<c10bdfa3>] pcpu_alloc+0x6ba/0x73b
> Feb 27 13:44:27 werner kernel:  [<c10bb0be>] ? get_slab+0x8/0x50
> Feb 27 13:44:27 werner kernel:  [<c1b7283d>] ? neigh_parms_alloc+0x55/0xd1
> Feb 27 13:44:27 werner kernel:  [<c10be047>] __alloc_percpu+0xf/0x14
> Feb 27 13:44:27 werner kernel:  [<c1bb26cb>] snmp_mib_init+0x22/0x5a
> Feb 27 13:44:27 werner kernel:  [<fee155af>] ipv6_add_dev+0x191/0x30b [ipv6]
> Feb 27 13:44:27 werner kernel:  [<f9185000>] ? inet6_init+0x0/0x2a2 [ipv6]
> Feb 27 13:44:27 werner kernel:  [<f91852ec>] addrconf_init+0x3b/0x11b [ipv6]
> Feb 27 13:44:27 werner kernel:  [<f9185195>] inet6_init+0x195/0x2a2 [ipv6]
> Feb 27 13:44:27 werner kernel:  [<c1001143>] do_one_initcall+0x51/0x13f
> Feb 27 13:44:27 werner kernel:  [<c1066570>] sys_init_module+0xac/0x1e0
> Feb 27 13:44:27 werner kernel:  [<c1c6acec>] syscall_call+0x7/0xb

Methinks Tejun's stuff broke, and then triggered a bug in a
hitherto-untested networking error recovery codepath.


> Feb 27 13:44:27 werner kernel: BUG: unable to handle kernel paging request at fed348d4
> Feb 27 13:44:27 werner kernel: IP: [<c1b68700>] unregister_pernet_operations+0x21/0x93
> Feb 27 13:44:27 werner kernel: *pde = 360fc067 *pte = 00000000 
> Feb 27 13:44:27 werner kernel: Oops: 0002 [#1] PREEMPT SMP 
> Feb 27 13:44:27 werner kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:0d.0/boot_vga
> Feb 27 13:44:27 werner kernel: Modules linked in: ipv6(+) bnep rfcomm hidp l2cap bluetooth snd_usb_audio snd_usb_lib snd_rawmidi snd_seq_device rt2860sta(C) uvcvideo usbvideo lp snd_hda_codec_analog rtc_cmos rtc_core rtc_lib rtl8187 tpm_tis tpm tpm_bios mac80211 led_class snd_hda_intel snd_hda_codec k8temp hwmon 8139too cfg80211 snd_hwdep snd_pcm rfkill snd_timer snd soundcore snd_page_alloc forcedeth i2c_nforce2
> Feb 27 13:44:27 werner kernel: 
> Feb 27 13:44:27 werner kernel: Pid: 5772, comm: modprobe Tainted: G         C 2.6.33 #1 M2N-VM DH/System Product Name
> Feb 27 13:44:27 werner kernel: EIP: 0060:[<c1b68700>] EFLAGS: 00010246 CPU: 0
> Feb 27 13:44:27 werner kernel: EIP is at unregister_pernet_operations+0x21/0x93
> Feb 27 13:44:27 werner kernel: EAX: fed348d4 EBX: fee39850 ECX: f0d7bf58 EDX: fee398d4
> Feb 27 13:44:27 werner kernel: ESI: fee39850 EDI: f9185000 EBP: f0d7bf6c ESP: f0d7bf58
> Feb 27 13:44:27 werner kernel:  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Feb 27 13:44:27 werner kernel: Process modprobe (pid: 5772, ti=f0d7a000 task=f0ccb660 task.ti=f0d7a000)
> Feb 27 13:44:27 werner kernel: Stack:
> Feb 27 13:44:27 werner kernel:  f0d7bf58 f0d7bf58 fee39850 00000000 f9185000 f0d7bf78 c1b687c6 fffffff4
> Feb 27 13:44:27 werner kernel: <0> f0d7bf84 f9185257 fee3b834 f0d7bf9c c1001143 00000000 fee3b834 00000000
> Feb 27 13:44:27 werner kernel: <0> 0805e188 f0d7bfac c1066570 b7516008 0805e138 f0d7a000 c1c6acec b7516008
> Feb 27 13:44:27 werner kernel: Call Trace:
> Feb 27 13:44:27 werner kernel:  [<f9185000>] ? inet6_init+0x0/0x2a2 [ipv6]
> Feb 27 13:44:27 werner kernel:  [<c1b687c6>] ? unregister_pernet_subsys+0x1c/0x29
> Feb 27 13:44:27 werner kernel:  [<f9185257>] ? inet6_init+0x257/0x2a2 [ipv6]
> Feb 27 13:44:27 werner kernel:  [<c1001143>] ? do_one_initcall+0x51/0x13f
> Feb 27 13:44:27 werner kernel:  [<c1066570>] ? sys_init_module+0xac/0x1e0
> Feb 27 13:44:27 werner kernel:  [<c1c6acec>] ? syscall_call+0x7/0xb
> Feb 27 13:44:27 werner kernel: Code: c2 75 e5 e8 78 0a 51 ff eb 97 55 89 e5 57 56 53 83 ec 08 e8 03 b2 49 ff 89 c6 8d 4d ec 89 4d ec 89 4d f0 8b 10 8b 40 04 89 42 04 <89> 10 c7 06 00 01 10 00 c7 46 04 00 02 20 00 a1 b8 b7 10 c2 8d 
> Feb 27 13:44:27 werner kernel: EIP: [<c1b68700>] unregister_pernet_operations+0x21/0x93 SS:ESP 0068:f0d7bf58
> Feb 27 13:44:27 werner kernel: CR2: 00000000fed348d4
> Feb 27 13:44:27 werner kernel: ---[ end trace 120df121853896c9 ]---
> Feb 27 13:45:39 werner kernel: BUG: Bad page map in process kio_http  pte:fee39850 pmd:ace05067
> Feb 27 13:45:39 werner kernel: addr:b6635000 vm_flags:08000075 anon_vma:(null) mapping:f20f434c index:5d
> Feb 27 13:45:39 werner kernel: vma->vm_ops->fault: filemap_fault+0x0/0x2eb
> Feb 27 13:45:39 werner kernel: vma->vm_file->f_op->mmap: generic_file_mmap+0x0/0x44
> Feb 27 13:45:39 werner kernel: Pid: 5764, comm: kio_http Tainted: G      D  C 2.6.33 #1
> Feb 27 13:45:39 werner kernel: Call Trace:
> Feb 27 13:45:39 werner kernel:  [<c10a47c7>] print_bad_pte+0x17e/0x190
> Feb 27 13:45:39 werner kernel:  [<c10a5782>] unmap_vmas+0x444/0x676
> Feb 27 13:45:39 werner kernel:  [<c10a461d>] ? __do_fault+0x3bd/0x3e9
> Feb 27 13:45:39 werner kernel:  [<c10988b9>] ? ____pagevec_lru_add+0x101/0x10f
> Feb 27 13:45:39 werner kernel:  [<c10a9344>] exit_mmap+0xab/0x13a
> Feb 27 13:45:39 werner kernel:  [<c1038cc1>] mmput+0x3a/0xb0
> Feb 27 13:45:39 werner kernel:  [<c103c669>] exit_mm+0xec/0xf4
> Feb 27 13:45:39 werner kernel:  [<c1c6a525>] ? _raw_spin_lock_irq+0xb/0x34
> Feb 27 13:45:39 werner kernel:  [<c1c6a855>] ? _raw_spin_unlock_irq+0x8/0x27
> Feb 27 13:45:39 werner kernel:  [<c103dbc1>] do_exit+0x1ad/0x605
> Feb 27 13:45:39 werner kernel:  [<c105554c>] ? up_read+0x8/0x18
> Feb 27 13:45:39 werner kernel:  [<c103e080>] do_group_exit+0x67/0x8a
> Feb 27 13:45:39 werner kernel:  [<c103e0bb>] sys_exit_group+0x18/0x1c
> Feb 27 13:45:39 werner kernel:  [<c1c6acec>] syscall_call+0x7/0xb
> 

