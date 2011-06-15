From: Vishal Study <vishal.study@gmail.com>
Subject: kernel 2.6.32-27 crash in tcp
Date: Wed, 15 Jun 2011 05:57:29 -0700
Message-ID: <BANLkTinhBMsWyj2ArfBiXYJpTqk=8XHm3A@mail.gmail.com>
References: <BANLkTi=pgbKHtSX9rhnunvoYYQjMMtdpPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=pgbKHtSX9rhnunvoYYQjMMtdpPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm using kernel 2.6.32-27 on a mips platform and get following kernel crash.

I'm running open-source IET iSCSI Stack and get this error during
heavy load test. Any ideas on what could be happening or if this is
known issue in 2.6.32 kernel?

Thanks,
Vishal.

------------[ cut here ]------------
WARNING: at net/ipv4/tcp.c:1457 tcp_recvmsg+0x7c0/0x990()
recvmsg bug 2: copied 8D07C2AD seq 1EAA6653 rcvnxt 8D083A71 fl 4000
Modules linked in: iscsi_trgt test_ethernet ipv6
Call Trace:
[<ffffffff801127d0>] dump_stack+0x8/0x34
[<ffffffff8024a8e8>] warn_slowpath_common+0x70/0xb0
[<ffffffff8024a97c>] warn_slowpath_fmt+0x34/0x40
[<ffffffff805c0130>] tcp_recvmsg+0x7c0/0x990
[<ffffffff8057bd8c>] sock_common_recvmsg+0x34/0x58
[<ffffffff8057a050>] sock_recvmsg+0x100/0x140
[<ffffffffc0081800>] do_recv+0x120/0x238 [iscsi_trgt]
[<ffffffffc0081ef8>] istd+0x5e0/0x1408 [iscsi_trgt]
[<ffffffff80264820>] kthread+0x88/0x90
[<ffffffff80221ea8>] kernel_thread_helper+0x10/0x18
