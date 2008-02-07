From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG][AX25] Fwd: SMP with AX.25
Date: Thu, 7 Feb 2008 20:34:26 +0100
Message-ID: <20080207193426.GA8149@ami.dom.local>
References: <00f201c8694a$2770f630$453c822c@dg8ngn> <cd9157050802071100m76a742bbyb18f4448d8ec436b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Jann Traschewski <jann@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:41169 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbYBGTar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 14:30:47 -0500
Received: by ug-out-1314.google.com with SMTP id z38so749262ugc.16
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2008 11:30:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> ---------- Forwarded message ----------
> From: Jann Traschewski <jann@gmx.de>
> Date: Thu, 7 Feb 2008 06:27:38 +0100
> Subject: FW: smp kernel oops ax25 2008-02-07
> To: Jarek Poplawski <jarkao2@gmail.com>
...
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 00000065
> printing eip: c02266c7 *pde = 00000000
> Oops: 0000 [#1] SMP
> Modules linked in: netconsole ppp_deflate zlib_deflate zlib_inflate bsd_comp
> ppp_async ppp_generic slhc tun bitrev crc32 mkiss ax25 crc16 iptable_nat
> nf_nat nf_conntrack_ipv4 xt_state nf_conntrack ipt_REJECT iptable_filter
> iptable_mangle xt_MARK ipv6 ipip tunnel4 ide_cd cdrom aic7xxx
> scsi_transport_spi parport_serial parport_pc parport i2c_piix4 genrtc
> 
> Pid: 19761, comm: frmaster Not tainted (2.6.24-dg8ngn #1)
> EIP: 0060:[<c02266c7>] EFLAGS: 00010297 CPU: 1
> EIP is at skb_clone+0x3/0x4d
> EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX: 00000020
> ESI: 00000008 EDI: 00000000 EBP: c0cfc8ac ESP: d3cfddc4
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process frmaster (pid: 19761, ti=d3cfc000 task=f7fbf570 task.ti=d3cfc000)
> Stack: c0cfc800 f8a0a8f9 c0cfc800 d3cfdf6c 00000007 00000015 c0cfc8cc
> e84492e0
>        c0cfc800 d3cfdf64 f6e6fbc0 f8a0e9d8 d3cfde60 00000000 c1d8c340
> d3cfdea0
>        c0cfc800 f5d12200 d3cfdf24 c014143d 01e7a9be 00000000 d3cfdf24
> 00000022
> Call Trace:
>  [<f8a0a8f9>] ax25_kick+0xaf/0x184 [ax25]
>  [<f8a0e9d8>] ax25_sendmsg+0x35f/0x49a [ax25]
>  [<c014143d>] __generic_file_aio_write_nolock+0x474/0x4d3
>  [<c0221214>] sock_aio_write+0xbc/0xc8
>  [<c01414f7>] generic_file_aio_write+0x5b/0xb0
>  [<c015a1d3>] do_sync_write+0xc7/0x10a
>  [<c022b643>] dev_hard_start_xmit+0x20a/0x26a
>  [<c012db6d>] autoremove_wake_function+0x0/0x35
>  [<c01253d3>] lock_timer_base+0x19/0x35
>  [<c015a960>] vfs_write+0x9e/0x10c
>  [<c015aeb7>] sys_write+0x41/0x67
>  [<c0103e4e>] syscall_call+0x7/0xb
>  =======================
> Code: 24 20 89 7c 24 08 89 44 24 04 03 aa 9c 00 00 00 89 2c 24 e8 cc 67 f9
> ff 89 44 24 54 8b 44 24 54 83 c4 3c 5b 5e 5f 5d c3 53 89 c3 <8a> 40 65 24 18
> 3c 08 75 1f 8d 8b a8 00 00 00 f6 41 65 18 75 13
> EIP: [<c02266c7>] skb_clone+0x3/0x4d SS:ESP 0068:d3cfddc4
> ---[ end trace 504af05b5c529aa1 ]---
