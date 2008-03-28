From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10350] New: SYN flooding crashed the kernel?
Date: Fri, 28 Mar 2008 12:26:55 -0700
Message-ID: <20080328122655.bcd51ccf.akpm@linux-foundation.org>
References: <bug-10350-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: harterc1@comcast.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55740 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754255AbYC1T1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 15:27:35 -0400
In-Reply-To: <bug-10350-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 28 Mar 2008 12:17:43 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10350
> 
>            Summary: SYN flooding crashed the kernel?
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.2-default #1 SMP
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: harterc1@comcast.net
> 
> 
> Latest working kernel version:
> Earliest failing kernel version:
> Distribution: Suse 10.3 untainted
> Hardware Environment: AMD
> Software Environment: KDE
> Problem Description: kernel crashed when running ktorrent
> 
> Steps to reproduce: haven't yet
> Mar 28 13:40:27 (none) syslog-ng[2578]: STATS: dropped 0
> Mar 28 13:47:04 (none) kernel: general protection fault: 0000 [1] SMP
> Mar 28 13:47:04 (none) kernel: CPU 1
> Mar 28 13:47:04 (none) kernel: Modules linked in: af_packet snd_pcm_oss
> snd_mixer_oss snd_seq snd_seq_device ip6t_REJECT cpufreq_conservative
> cpufreq_ondemand cpufreq_userspace cpufreq_powersave powernow_k8
> ip6table_mangle freq_table ip6table_filter ip6_tables ipv6 fuse dm_crypt loop
> dm_mod snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd soundcore
> i2c_nforce2 button snd_page_alloc forcedeth i2c_core sg sd_mod edd fan generic
> thermal processor
> Mar 28 13:47:04 (none) kernel: Pid: 5733, comm: ktorrent Not tainted
> 2.6.24.2-default #1
> Mar 28 13:47:04 (none) kernel: RIP: 0010:[<ffffffff802866c1>] 
> [<ffffffff802866c1>] kfree+0x6c/0x9f
> Mar 28 13:47:04 (none) kernel: RSP: 0018:ffff8100249c7ba8  EFLAGS: 00010082
> Mar 28 13:47:04 (none) kernel: RAX: 0000000000000001 RBX: ffff810001000000 RCX:
> 0000000000000001
> Mar 28 13:47:04 (none) kernel: RDX: ffff810001596e28 RSI: ffff810043e042c0 RDI:
> ff0081007f8036c0
> Mar 28 13:47:04 (none) kernel: RBP: 0000000000000286 R08: 00000000f8a1426c R09:
> 0000000000000000
> Mar 28 13:47:04 (none) kernel: R10: ffff810043e042c0 R11: ffffffff802fdbb8 R12:
> ffff8100198d3000
> Mar 28 13:47:04 (none) kernel: R13: 0000000000000000 R14: 0000000000000000 R15:
> 000000000000020c
> Mar 28 13:47:04 (none) kernel: FS:  0000000040800950(0063)
> GS:ffff81007f876cc0(0000) knlGS:00000000b732c9a0
> Mar 28 13:47:04 (none) kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
> 0000000080050033
> Mar 28 13:47:04 (none) kernel: CR2: 00002aaaafc04150 CR3: 0000000070dd7000 CR4:
> 00000000000006e0
> Mar 28 13:47:04 (none) kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> Mar 28 13:47:04 (none) kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> Mar 28 13:47:04 (none) kernel: Process ktorrent (pid: 5733, threadinfo
> ffff8100249c6000, task ffff81005f86a840)
> Mar 28 13:47:04 (none) kernel: Stack:  ffff810043e042c0 ffff810043e042c0
> 000000000000020c ffffffff80428a36
> Mar 28 13:47:04 (none) kernel:  ffff810024999880 ffffffff804665be
> 0000000000000000 000000005f86a840
> Mar 28 13:47:04 (none) kernel:  ffff810024999d28 0000000000100100
> ffff810024999c80 ffff810024999930
> Mar 28 13:47:04 (none) kernel: Call Trace:
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80428a36>] __kfree_skb+0x9/0x6f
> Mar 28 13:47:04 (none) kernel:  [<ffffffff804665be>] tcp_recvmsg+0x614/0x808
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80424e56>]
> sock_common_recvmsg+0x30/0x45
> Mar 28 13:47:04 (none) kernel:  [<ffffffff804235f6>] sock_recvmsg+0xf0/0x10f
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80231288>]
> default_wake_function+0x0/0xe
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80249e8d>]
> autoremove_wake_function+0x0/0x2e
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80231288>]
> default_wake_function+0x0/0xe
> Mar 28 13:47:04 c-76-22-167-36 syslog-ng[2578]: last message repeated 2 times
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80251998>] do_futex+0x8d/0xa3d
> Mar 28 13:47:04 (none) kernel:  [<ffffffff804246ce>] sys_recvfrom+0xe2/0x130
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80425572>] release_sock+0x13/0x9a
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80464c80>] tcp_ioctl+0x11a/0x126
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80422ddb>] sock_ioctl+0x1dc/0x200
> Mar 28 13:47:04 (none) kernel:  [<ffffffff80295451>] do_ioctl+0x21/0x6b
> Mar 28 13:47:04 (none) kernel:  [<ffffffff8020beee>] system_call+0x7e/0x83
> Mar 28 13:47:04 (none) kernel:
> Mar 28 13:47:04 (none) kernel:
> Mar 28 13:47:04 (none) kernel:
> Mar 28 13:47:04 (none) kernel: Code: 48 8b 1c c7 8b 13 3b 53 04 73 0c 89 d0 4c
> 89 64 c3 18 8d 42
> Mar 28 13:47:04 (none) kernel: RIP  [<ffffffff802866c1>] kfree+0x6c/0x9f
> Mar 28 13:47:04 (none) kernel:  RSP <ffff8100249c7ba8>
> Mar 28 13:47:04 (none) kernel: ---[ end trace 5b58994d2438c622 ]---
> Mar 28 13:49:37 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 13:50:53 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 13:52:48 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 13:54:21 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 13:58:44 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 13:59:46 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 14:03:16 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> Mar 28 14:07:00 (none) kernel: possible SYN flooding on port 6881. Sending
> cookies.
> 

So all the syn-flooding messages came _after_ the crash?

If so, the messages are possibly a consequence of the crash - the
networking state was left screwed up.

If this happened a single time on a single machine then perhaps you have an
intermittent hardware failure - we'll probably wait this one out, see if
other machines exhibit it, or if a means of reproducing it emerges.

