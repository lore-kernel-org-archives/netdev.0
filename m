From: Vishal Study <vishal.study@gmail.com>
Subject: kernel 2.6.32-27 crash in tcp
Date: Tue, 14 Jun 2011 19:43:34 -0700
Message-ID: <BANLkTi=pgbKHtSX9rhnunvoYYQjMMtdpPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vishal.study@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f66.google.com ([209.85.212.66]:41319 "EHLO
	mail-vw0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508Ab1FOCnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 22:43:35 -0400
Received: by vwl1 with SMTP id 1so856412vwl.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 19:43:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm using kernel 2.6.32-27 on a MIPS platform and get following kernel crash.

I'm running open-source IET iSCSI Stack and get this error during
heavy load test. Any ideas on what could be happening or if this is
known issue?

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
