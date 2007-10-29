From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: last git: BUG: unable to handle kernel paging request at
 virtual address 92184900
Date: Mon, 29 Oct 2007 01:11:48 -0700
Message-ID: <20071029011148.76ae8dd4.akpm@linux-foundation.org>
References: <471E45B4.9050504@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Giacomo Catenazzi <cate@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52405 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752204AbXJ2IMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 04:12:22 -0400
In-Reply-To: <471E45B4.9050504@debian.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Oct 2007 21:04:20 +0200 Giacomo Catenazzi <cate@debian.org> wrote:

> Hello people,
> 
> I've still some kernel bug
> 
> ciao
> 	cate
> 
> Oct 23 20:20:05 catee kernel: BUG: unable to handle kernel paging request at virtual address 92184900
> Oct 23 20:20:05 catee kernel: printing eip: c017b9c2 *pde = 00000000
> Oct 23 20:20:05 catee kernel: Oops: 0002 [#1] SMP
> Oct 23 20:20:05 catee kernel: Modules linked in: fuse tuner tea5767 tda8290 tuner_simple mt20xx floppy bttv ir_common videobuf_dma_sg btcx_risc tveeprom
> Oct 23 20:20:05 catee kernel:
> Oct 23 20:20:05 catee kernel: Pid: 2191, comm: dirmngr Not tainted (2.6.23-g0b776eb5 #16)
> Oct 23 20:20:05 catee kernel: EIP: 0060:[<c017b9c2>] EFLAGS: 00010203 CPU: 2
> Oct 23 20:20:05 catee kernel: EIP is at generic_drop_inode+0x5d/0x147
> Oct 23 20:20:05 catee kernel: EAX: c478b238 EBX: c478b228 ECX: c2491600 EDX: c4d170b8
> Oct 23 20:20:05 catee kernel: ESI: c2405f40 EDI: c478b228 EBP: c4933940 ESP: c3798e90
> Oct 23 20:20:05 catee kernel: DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Oct 23 20:20:05 catee kernel: Process dirmngr (pid: 2191, ti=c3798000 task=c2c99ab0 task.ti=c3798000)
> Oct 23 20:20:05 catee kernel: Stack: c478b228 c017b00d c5046314 c01791bf c5046314 c2405f40 c017a0d7 00000008
> Oct 23 20:20:05 catee kernel: c016b622 00000010 00000000 c5046314 c478b228 c037f600 c478b200 c2832200
> Oct 23 20:20:05 catee kernel: 00000000 c02f9a4d 00000000 c20107b4 c2469ae0 00000000 00000001 ffffffff
> Oct 23 20:20:05 catee kernel: Call Trace:
> Oct 23 20:20:05 catee kernel: [<c017b00d>] iput+0x5c/0x62
> Oct 23 20:20:05 catee kernel: [<c01791bf>] d_kill+0x2b/0x44
> Oct 23 20:20:05 catee kernel: [<c017a0d7>] dput+0x6d/0xf3
> Oct 23 20:20:05 catee kernel: [<c016b622>] __fput+0x124/0x169
> Oct 23 20:20:05 catee kernel: [<c02f9a4d>] sys_accept+0x17b/0x1d8
> Oct 23 20:20:05 catee kernel: [<c013527f>] autoremove_wake_function+0x0/0x35
> Oct 23 20:20:05 catee kernel: [<c013d617>] tick_program_event+0x38/0x58
> Oct 23 20:20:05 catee kernel: [<c02f9cb2>] sys_socketcall+0x208/0x273
> Oct 23 20:20:05 catee kernel: [<c0103fde>] sysenter_past_esp+0x5f/0x85
> Oct 23 20:20:05 catee kernel: =======================
> Oct 23 20:20:05 catee kernel: Code: 8b 43 14 89 42 04 89 10 8d 43 10 89 43 10 89 43 14 83 8b 44 01 00 00 20 83 2d 40 e8 49 c0 01 08 05 e4 27 41 c0 01 8b 83 e0 00 00 <00> 85 c0 0f 85 cd 00 00 00 89 d8 e8 e3 fd ff ff 89 d8 e8 b0 f5

Is this still happening in the latest Linus tree?

If so, please send some more oops traces so we can see if it's always happening
in the same place.

Please only send the first oops trace after a bootup: the one with [#1] in
the "Oops:" line.  All the others could be a consequence of the first.

Thanks.
