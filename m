From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.0-rc2: skb_put() -> skb_over_panic
Date: Sun, 15 Apr 2012 17:16:04 +0200
Message-ID: <1334502964.28012.1.camel@edumazet-glaptop>
References: <CAA1sL1QTRKnfvCnHWjbSJ-hq6dgZK+KGDPVTrOhsfZcFTs01Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA1sL1QTRKnfvCnHWjbSJ-hq6dgZK+KGDPVTrOhsfZcFTs01Mw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-15 at 16:24 +0400, Alexander Beregalov wrote:
> Hi
> 
> kernel 3.4.0-rc2-00333-g668ce0a
> 
> calltrace is lost on netconsole, sorry.
> 
> ethernet is realtek/r8169
> 
> It happened already two times with rtorrent, perhaps I can reproduce
> it, what else can I provide to you?
> 
> skb_over_panic: text:ffffffff8136d919 len:1016 put:815
> head:ffff8800afe4d800 data:ffff8800afe4dd6b tail:0x963 end:0x6c0
> dev:<NULL>
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:127!
> invalid opcode: 0000 [#1] SMP
> CPU 2
> Modules linked in:
> 
> Pid: 0, comm: swapper/2 Not tainted 3.4.0-rc2-00333-g668ce0a #1
>           /D525MW
> RIP: 0010:[<ffffffff8132414a>]  [<ffffffff8132414a>] skb_put+0x7c/0x86
> RSP: 0018:ffff8800bed03950  EFLAGS: 00010246
> RAX: 0000000000000098 RBX: ffff88002883a580 RCX: 0000000000000015
> RDX: 0000000000000001 RSI: 0000000000000046 RDI: ffffffff8162a0b0
> RBP: ffff8800bed03970 R08: ffffffff813cd540 R09: ffff8800bed03650
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff88002895c380
> R13: ffff88002895ca80 R14: ffff88002895c3a8 R15: ffff88002883a660
> FS:  0000000000000000(0000) GS:ffff8800bed00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fcbba6e1000 CR3: 0000000001520000 CR4: 00000000000007e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper/2 (pid: 0, threadinfo ffff8800bb0a8000, task ffff8800bb06d780)
> Stack:
>  0000000000000963 00000000000006c0 ffffffff814d06e7 ffff88002895c380
>  ffff8800bed039d0 ffffffff8136d919 ffff88000000032f 000000c98102ebbd
>  ffff88002883a660 0000019c0000250f ffff88002883a580 ffff88002883a580
> Call Trace:
>  <IRQ>
> --

full stack trace needed please.
