From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Tue, 30 Sep 2008 11:40:39 +0200
Message-ID: <48E1F417.7080304@free.fr>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7-g19.free.fr ([212.27.42.64]:45873 "EHLO smtp7-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088AbYI3Jko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 05:40:44 -0400
In-Reply-To: <20080929123036.GA16954@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

Yes this is a vanilla kernel, which makes it interesting to debug.
I forgot to Cc: Ralf and put it now on copy of this message.
Thank you for the patch I applied.
Collected data includes both events I already reported, first the 
inconsistent lock state, second the kernel bug followed by a kernel 
panic. The second event only occured after I intentionally started, 
after a while, FPAC application using rose protocole .

  ------------------------------
  mar sep 30 11:02:35 CEST 2008
  ------------------------------
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c6782c38, 00000000, 2, 1, 6
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c6782058, 00000000, 2, 1, 6
  AX25_DBG: c66b8038, 00000000, 10, 1, 6
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c6782058, 00000000, 2, 1, 6
  AX25_DBG: c66b8038, 00000000, 10, 1, 6
  AX25_DBG: c6515998, 00000000, 1, 1, 0
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c6589778, 00000000, 16, 3, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c6589778, 00000000, 16, 3, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c6589778, 00000000, 16, 3, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c6515998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c6515998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c6589360, 00000000, 16, 3, 9
  AX25_DBG: c6589360, 00000000, 16, 3, 9
  AX25_DBG: c6515998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c6515998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c6589360, 00000000, 16, 3, 9
  AX25_DBG: c6589360, 00000000, 16, 3, 9
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c64bbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c7bbbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c7bbbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c7bbbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c7bbbcc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c67cccc8, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c67cccc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cccc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 0, 0
  AX25_DBG: c67cc338, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0

  =================================
  [ INFO: inconsistent lock state ]
  2.6.27-rc7 #3
  ---------------------------------
  inconsistent {in-softirq-W} -> {softirq-on-W} usage.
  syslogd/2474 [HC0[0]:SC0[0]:HE1:SE1] takes:
   (_xmit_ETHER#2){-+..}, at: [<c0265562>] netpoll_send_skb+0x132/0x190
  {in-softirq-W} state was registered at:
    [<c01402a8>] __lock_acquire+0x3e8/0x9b0
    [<c01408e5>] lock_acquire+0x75/0xa0
    [<c02bff15>] _spin_lock+0x35/0x60
    [<c0267fcd>] __qdisc_run+0x14d/0x1e0
    [<c025a708>] dev_queue_xmit+0x1c8/0x4d0
    [<c0260559>] neigh_resolve_output+0xe9/0x290
    [<c8c29ee5>] ip6_output_finish+0x85/0xc0 [ipv6]
    [<c8c2a43b>] ip6_output2+0x1ab/0x1c0 [ipv6]
    [<c8c2b5d4>] ip6_output+0x4b4/0xb10 [ipv6]
    [<c8c44553>] mld_sendpack+0x2b3/0x2e0 [ipv6]
    [<c8c45695>] mld_ifc_timer_expire+0x175/0x260 [ipv6]
    [<c0125e29>] run_timer_softirq+0x149/0x1b0
    [<c0121ce5>] __do_softirq+0x55/0xc0
    [<c0121d96>] do_softirq+0x46/0x50
    [<c0122107>] irq_exit+0x57/0x70
    [<c010639f>] do_IRQ+0x4f/0xa0
    [<c01045e4>] common_interrupt+0x28/0x30
    [<c0134875>] __atomic_notifier_call_chain+0x45/0x90
    [<c01348da>] atomic_notifier_call_chain+0x1a/0x20
    [<c0216ece>] notify_write+0x1e/0x20
    [<c02195f9>] do_con_write+0x509/0x1a60
    [<c021aba4>] con_write+0x14/0x30
    [<c020cb4c>] write_chan+0x18c/0x330
    [<c020ab0f>] tty_write+0x12f/0x1d0
    [<c01714c9>] do_loop_readv_writev+0x39/0x70
    [<c0171ec8>] do_readv_writev+0x158/0x160
    [<c0171f0f>] vfs_writev+0x3f/0x60
    [<c017224d>] sys_writev+0x3d/0x70
    [<c0103bbd>] sysenter_do_call+0x12/0x35
    [<ffffffff>] 0xffffffff
  irq event stamp: 851757
  hardirqs last  enabled at (851757): [<c013e9db>] 
trace_hardirqs_on+0xb/0x10
  hardirqs last disabled at (851756): [<c013b8eb>] 
trace_hardirqs_off+0xb/0x10
  softirqs last  enabled at (851752): [<c0121d33>] __do_softirq+0xa3/0xc0
  softirqs last disabled at (851743): [<c0121d96>] do_softirq+0x46/0x50

  other info that might help us debug this:
  2 locks held by syslogd/2474:
   #0:  (&tty->atomic_write_lock){--..}, at: [<c020a8fc>] 
tty_write_lock+0x1c/0x50
   #1:  (target_list_lock){--..}, at: [<c8ab510d>] write_msg+0x2d/0xe0 
[netconsole]

  stack backtrace:
  Pid: 2474, comm: syslogd Not tainted 2.6.27-rc7 #3
   [<c013ccab>] print_usage_bug+0x16b/0x1a0
   [<c013e551>] mark_lock+0x8c1/0xae0
   [<c0108b17>] ? native_sched_clock+0x77/0xb0
   [<c01402ee>] __lock_acquire+0x42e/0x9b0
   [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
   [<c025189c>] ? skb_dequeue+0x4c/0x70
   [<c01408e5>] lock_acquire+0x75/0xa0
   [<c0265562>] ? netpoll_send_skb+0x132/0x190
   [<c02bfc10>] _spin_trylock+0x40/0x50
   [<c0265562>] ? netpoll_send_skb+0x132/0x190
   [<c0265562>] netpoll_send_skb+0x132/0x190
   [<c0265a5d>] netpoll_send_udp+0x1ed/0x200
   [<c8ab517c>] write_msg+0x9c/0xe0 [netconsole]
   [<c8ab50e0>] ? write_msg+0x0/0xe0 [netconsole]
   [<c011d5e7>] __call_console_drivers+0x47/0x60
   [<c011d679>] _call_console_drivers+0x79/0x90
   [<c011da50>] release_console_sem+0xc0/0x1e0
   [<c0219251>] do_con_write+0x161/0x1a60
   [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
   [<c013e7d1>] ? mark_held_locks+0x61/0x80
   [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
   [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
   [<c011db37>] ? release_console_sem+0x1a7/0x1e0
   [<c021aba4>] con_write+0x14/0x30
   [<c020cb4c>] write_chan+0x18c/0x330
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c020ab0f>] tty_write+0x12f/0x1d0
   [<c020c9c0>] ? write_chan+0x0/0x330
   [<c01714c9>] do_loop_readv_writev+0x39/0x70
   [<c0171ec8>] do_readv_writev+0x158/0x160
   [<c020a9e0>] ? tty_write+0x0/0x1d0
   [<c0171f0f>] vfs_writev+0x3f/0x60
   [<c017224d>] sys_writev+0x3d/0x70
   [<c0103bbd>] sysenter_do_call+0x12/0x35
   =======================
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  mkiss: ax1: crc mode is auto.
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc668, 00000000, 1, 1, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  AX25_DBG: c67cc668, 00000000, 1, 2, 0
  ADDRCONF(NETDEV_CHANGE): ax1: link becomes ready
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  mkiss: ax2: crc mode is auto.
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  ADDRCONF(NETDEV_CHANGE): ax2: link becomes ready
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  mkiss: ax3: crc mode is auto.
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  ADDRCONF(NETDEV_CHANGE): ax3: link becomes ready
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c6782c38, 00000000, 2, 1, 6
  AX25_DBG: c66b9340, 00000000, 10, 1, 6
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c6782c38, 00000000, 2, 1, 6
  AX25_DBG: c66b9340, 00000000, 10, 1, 6
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c67cc008, 00000000, 1, 2, 0
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c67c64b8, 00000000, 3, 2, 240
  mkiss: ax4: crc mode is auto.
  AX25_DBG: c67cc338, 00000000, 1, 0, 0
  AX25_DBG: c67cc008, 00000000, 1, 1, 0
  AX25_DBG: c67cc338, 00000000, 1, 0, 0
  AX25_DBG: c67cc008, 00000000, 1, 1, 0
  AX25_DBG: c67cc338, 00000000, 1, 0, 0
  AX25_DBG: c67cc008, 00000000, 1, 1, 0
  AX25_DBG: c67cc338, 00000000, 1, 0, 0
  AX25_DBG: c67cc008, 00000000, 1, 1, 0
  AX25_DBG: c67cc008, 00000000, 1, 2, 0
  AX25_DBG: c67cc008, 00000000, 1, 2, 0
  ADDRCONF(NETDEV_CHANGE): ax4: link becomes ready
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c67cc338, 00000000, 1, 1, 0
  AX25_DBG: c663f350, 00000000, 2, 2, 17
  NET: Registered protocol family 6
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 0, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 0, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c4001cc8, 00000000, 1, 2, 0
  AX25_DBG: c4001cc8, 00000000, 1, 2, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c4001cc8, 00000000, 1, 0, 0
  AX25_DBG: c67cc998, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 1, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c4057140, 00000000, 3, 2, 240
  AX25_DBG: c40564f8, c51892b0, 6, 5, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c4057140, 00000000, 3, 2, 240
  AX25_DBG: c4084d08, c5189aa8, 6, 5, 0
  AX25_DBG: c6515338, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c40564f8, 00000000, 3, 2, 240
  AX25_DBG: c6719380, c51892b0, 6, 5, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c6719380, c51892b0, 6, 5, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c40564f8, c51892b0, 6, 5, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c4084d08, c51892b0, 6, 5, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  netromd uses obsolete (PF_INET,SOCK_PACKET)
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c4084d08, 00000000, 3, 2, 240
  AX25_DBG: c40840c0, c5195d50, 6, 5, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c6719380, 00000000, 3, 2, 240
  AX25_DBG: c4057140, c5189800, 6, 5, 0
  AX25_DBG: c67cc998, 00000000, 1, 2, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c64cb058, 00000000, 10, 2, 17
  AX25_DBG: c6719380, 00000000, 3, 2, 240
  AX25_DBG: c4081578, c5195d50, 6, 5, 0
  AX25_DBG: c64eaf08, 00000000, 16, 3, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c64eaf08, 00000000, 16, 3, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c64eaf08, 00000000, 16, 3, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  mkiss: ax0: Trying crc-smack
  mkiss: ax0: Trying crc-flexnet
  AX25_DBG: c64eaf08, 00000000, 3, 2, 207
  mkiss: ax1: Trying crc-smack
  mkiss: ax1: Trying crc-flexnet
  AX25_DBG: c64eaf08, 00000000, 3, 2, 207
  mkiss: ax3: Trying crc-smack
  mkiss: ax3: Trying crc-flexnet
  AX25_DBG: c64eaf08, 00000000, 3, 2, 207
  mkiss: ax4: Trying crc-smack
  mkiss: ax4: Trying crc-flexnet
  AX25_DBG: c64eaf08, 00000000, 3, 2, 207
  AX25_DBG: c64eaf08, c5189800, 6, 5, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c67d6ca8, 00000000, 11, 5, 0
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  ROSE: socket is bound
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c663f980, 00000000, 2, 2, 17
  AX25_DBG: c67615a0, 00000000, 11, 5, 0
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c663f668, 00000000, 2, 2, 17
  AX25_DBG: c401a550, 00000000, 11, 5, 0
  AX25_DBG: c4010120, c51a4aa8, 3, 5, 240
  ------------[ cut here ]------------
  kernel BUG at net/core/datagram.c:638!
  invalid opcode: 0000 [#1]
  Modules linked in: netrom rose mkiss crc16 ax25 netconsole configfs 
nfsd exportfs nfs lockd nfs_acl sunrpc af_packet ipv6 snd_seq_dummy 
snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss 
binfmt_misc loop usb_storage scsi_mod floppy usbhid snd_ens1371 
snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm snd_timer uhci_hcd snd 
soundcore intel_agp snd_page_alloc ac97_bus ide_cd_mod usbcore agpgart 
ne2k_pci 8390 ext3 jbd ide_disk piix ide_core [last unloaded: nf_conntrack]

  Pid: 3768, comm: fpad Not tainted (2.6.27-rc7 #3)
  EIP: 0060:[<c02546d9>] EFLAGS: 00010246 CPU: 0
  EIP is at datagram_poll+0xe9/0xf0
  EAX: 00006b6a EBX: c4010120 ECX: 00002059 EDX: 6b6b6b6b
  ESI: 00000001 EDI: 0000000b EBP: c408fb3c ESP: c408fb34
   DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
  Process fpad (pid: 3768, ti=c408e000 task=c6653310 task.ti=c408e000)
  Stack: c8c9a300 c65eb960 c408fb48 c024ab92 00000800 c408fe14 c017e495 
00000002
         00000001 00000000 c017e180 00000000 c408fbc4 c408ff9c c408ff48 
00000000
         0000000e c408fe54 c408fe58 c408fe5c c408fe4c c408fe50 c408fe54 
00003de0
  Call Trace:
   [<c024ab92>] ? sock_poll+0x12/0x20
   [<c017e495>] ? do_select+0x315/0x5a0
   [<c017e180>] ? do_select+0x0/0x5a0
   [<c017ec80>] ? __pollwait+0x0/0xd0
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c0117fa0>] ? default_wake_function+0x0/0x10
   [<c02bfd9d>] ? _spin_unlock+0x1d/0x20
   [<c02921c8>] ? udp_queue_rcv_skb+0x158/0x270
   [<c0291995>] ? __udp4_lib_lookup+0x105/0x130
   [<c02925fb>] ? __udp4_lib_rcv+0x31b/0x800
   [<c0121d33>] ? __do_softirq+0xa3/0xc0
   [<c017e90a>] ? core_sys_select+0x1ea/0x330
   [<c017e74d>] ? core_sys_select+0x2d/0x330
   [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
   [<c8c970fb>] ? ax25_ioctl+0xbb/0x690 [ax25]
   [<c8c98c17>] ? ax25_connect+0x1e7/0x470 [ax25]
   [<c024deff>] ? release_sock+0xbf/0xd0
   [<c01e6146>] ? copy_from_user+0x46/0x80
   [<c024b871>] ? sys_connect+0x91/0xb0
   [<c8ca09c4>] ? rose_ioctl+0x194/0x2c0 [rose]
   [<c024b105>] ? sock_ioctl+0x55/0x220
   [<c017ee1b>] ? sys_select+0xcb/0x190
   [<c0103bbd>] ? sysenter_do_call+0x12/0x35
   =======================
  Code: ca 83 ca 10 3c 07 0f b6 43 02 0f 44 ca 3c 02 75 b3 5b 89 c8 5e 
5d c3 b9 08 00 00 00 e9 5d ff ff ff 80 4a 08 01 5b 89 c8 5e 5d c3 <0f> 
0b eb fe 8d 76 00 55 89 e5 53 89 c3 89 d0 e8 f3 d5 ff ff 8b
  EIP: [<c02546d9>] datagram_poll+0xe9/0xf0 SS:ESP 0068:c408fb34
  Kernel panic - not syncing: Fatal exception
  Rebooting in 60 seconds..AX25_DBG: c67df1a0, c51a5d50, 3, 5, 240


Bernard

