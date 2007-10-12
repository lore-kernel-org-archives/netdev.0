From: xeb@mail.ru
Subject: Kernel panic (network stack)
Date: Fri, 12 Oct 2007 16:35:40 +0400
Message-ID: <200710121635.40414.xeb@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback.mail.ru ([194.67.57.14]:24288 "EHLO mx4.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbXJLMgm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:36:42 -0400
Received: from mx27.mail.ru (mx27.mail.ru [194.67.23.23])
	by mx4.mail.ru (mPOP.Fallback_MX) with ESMTP id 3A72D3907F
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 16:36:23 +0400 (MSD)
Received: from [195.218.214.30] (port=38338 helo=[192.168.2.7])
	by mx27.mail.ru with asmtp
	id 1IgJjx-000K7O-00
	for netdev@vger.kernel.org; Fri, 12 Oct 2007 16:35:41 +0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----------  =F0=C5=D2=C5=D3=CC=C1=CE=CE=CF=C5 =D3=CF=CF=C2=DD=C5=CE=C9=C5=
  ----------

=F4=C5=CD=C1: Kernel panic (network stack)
=E4=C1=D4=C1: 12 =CF=CB=D4=D1=C2=D2=D1 2007
=EF=D4=D0=D2=C1=D7=C9=D4=C5=CC=D8: xeb@mail.ru
=D0=CF=CC=D5=DE=C1=D4=C5=CC=D8:  linux-kernel@vger.kernel.org

Hello!
I develop network driver.
It works fine while less then 100 network interfaces exists.
Then i give kernel panic. What could cause it ?

general protection fault: 0000 [1] PREEMPT SMP
CPU 1
Modules linked in: ppp_deflate zlib_deflate zlib_inflate pptp pppox=20
ppp_generic slhc rtc 8139too=20
Pid: 0, comm: swapper Noy tainted 2.6.22-gentoo-r8 #5
RIP: 0010:[<ffffffff8025ec9b>] [<ffffffff8025ec9b>] put_page+0x1b/0x110
RSP: 0018:ffff81000171fda0 EFLAGS: 00010286
RAX: ffff81000ec31080 RBX: a2e9690005e3ffff RCX: 0000000000000000
RDX: 0000000000000000 RSI: 000000000000005a RDI: a2e9690005e3ffff
RBP: ffff81000ec31080 R08: ffff81000ec31046 R09: 0000000000000001
R10: 0000000000000000 R11: ffffffff80467910 R12: ffff81001a912800
R13: 0000000000000008 R14: ffffffff805f7440 R15: ffff81001a912800
=46S:  00002ad3cba47ae0(0000) GS: ffff81001be7df40(0000) knlGS: 0000000=
0f7e3b6b0
CS:  0010 DS: 0018 ES: 0018 CR0: 0000000008005003b
CR2: 0000000000413ae0 CR3: 00000000011ef000 CR4: 00000000000006e0
Process swapper (pid:0, threadinfo ffff810001718000, task ffff81001be6e=
730
Stack: 0000000000000000 0000000000000001 ffff81000f16f0c0 ffff81001a912=
800
 0000000000000008 fffffff80463ab7 ffff8100129d1e42 ffff81000f16f0c0
 ffff81000f16f0c0 fffffff80463859 ffffffff806081b0 ffffffff80489fb5
Call Trace:
<IRQ> [<ffffffff80463ab7>] skb_release_data+0x77/0xd0
[<ffffffff80463859>] kfree_skbmem+0x9/0x80
[<ffffffff80489fb5>] ip_rcv+0xc5/0x6a0
[<ffffffff8046aeb5>] netif_receive_skb+0x3f5/0x400
[<ffffffff8046ad58>] netif_receive_skb+0x298/0x400
[<ffffffff8046af5b>] process_backlog+0x9b/0x130
[<ffffffff8046b078>] net_rx_action+0x88/0x1d0
[<ffffffff8808e632>] :8139too:rtl8139_interrupt+0x142/0x550
[<ffffffff802335fb>] __do_softirq+0x6b/0xf0
[<ffffffff8020acbc>] call_softirq+0x1c/0x30
[<ffffffff8020cbda>] do_softirq+0x4a/0xb0
[<ffffffff8020cb10>] do_IRQ+0x80/0x100
[<ffffffff80207b40>] default_idle+0x0/0x50
[<ffffffff80209fe1>] ret_from_intr+0x0/0xa
<EOI> <ffffffff80207b69>] default_idle+0x29/0x50
[<ffffffff80207d90>] cpu_idle+0x90/0xa0


Code: 8b 07 f6 c4 40 0f 85 cc 00 00 00 f0 ff 4f 08 0f 94 c0 84 c0
RIP [<ffffffff8025ec9b>] put_page+0x1b/0x110
 RSP: 0018:ffff81000171fda0
Kernel panic - not syncing: Aiee, killing interrupt handler!




-------------------------------------------------------
