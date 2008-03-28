From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Fri, 28 Mar 2008 09:27:16 +0100
Message-ID: <47ECABE4.40405@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:39095 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753704AbYC1I1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 04:27:19 -0400
Received: from smtp5-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp5-g19.free.fr (Postfix) with ESMTP id B4F233F616E
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 09:27:17 +0100 (CET)
Received: from [192.168.0.66] (car75-2-82-66-61-83.fbx.proxad.net [82.66.61.83])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 582B63F614C
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 09:27:17 +0100 (CET)
In-Reply-To: <20080326183538.GA14266@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,


Here is the result of cat /var/log/messages | grep -B1 -A50 core/sock
No event was detected before 16:33.


--
Mar 27 16:33:05 f6bvp-9 kernel: sk_ax25_debug = 0, 11, 0, 5, c08922e0,
6b6b6b6b, c7790190
Mar 27 16:33:05 f6bvp-9 kernel: WARNING: at net/core/sock.c:1561
sock_def_write_space()
Mar 27 16:33:05 f6bvp-9 kernel: Pid: 3454, comm: mkiss Not tainted
2.6.24.4 #4
Mar 27 16:33:05 f6bvp-9 kernel:  [<c010513a>] show_trace_log_lvl+0x1a/0x30
Mar 27 16:33:05 f6bvp-9 kernel:  [<c0105b52>] show_trace+0x12/0x20
Mar 27 16:33:05 f6bvp-9 kernel:  [<c01064ac>] dump_stack+0x6c/0x80
Mar 27 16:33:05 f6bvp-9 kernel:  [<c024d68b>]
sock_def_write_space+0x17b/0x190
Mar 27 16:33:05 f6bvp-9 kernel:  [<c024da7a>] sock_wfree+0x3a/0x40
Mar 27 16:33:05 f6bvp-9 kernel:  [<c024fc3d>] skb_release_all+0x4d/0xf0
Mar 27 16:33:05 f6bvp-9 kernel:  [<c024f3eb>] __kfree_skb+0xb/0x90
Mar 27 16:33:05 f6bvp-9 kernel:  [<c024f489>] kfree_skb+0x19/0x30
Mar 27 16:33:05 f6bvp-9 kernel:  [<c8cbfe37>] ax_xmit+0xf7/0x360 [mkiss]
Mar 27 16:33:05 f6bvp-9 kernel:  [<c02554a7>]
dev_hard_start_xmit+0x207/0x270
Mar 27 16:33:05 f6bvp-9 kernel:  [<c0265934>] __qdisc_run+0x54/0x1a0
Mar 27 16:33:05 f6bvp-9 kernel:  [<c0257cec>] dev_queue_xmit+0x25c/0x330
Mar 27 16:33:05 f6bvp-9 kernel:  [<c8befa77>] ax25_queue_xmit+0x47/0x70
[ax25]
Mar 27 16:33:05 f6bvp-9 kernel:  [<c8befb65>]
ax25_transmit_buffer+0xc5/0x110 [ax25]
Mar 27 16:33:05 f6bvp-9 kernel:  [<c8befc2d>]
ax25_send_iframe+0x7d/0x110 [ax25]
Mar 27 16:33:06 f6bvp-9 kernel:  [<c8befd70>] ax25_kick+0xb0/0x2b0 [ax25]
Mar 27 16:33:06 f6bvp-9 kernel:  [<c8bf10c9>]
ax25_std_frame_in+0x69/0x890 [ax25]
Mar 27 16:33:06 f6bvp-9 kernel:  [<c8beedba>] ax25_kiss_rcv+0x2ba/0x7b0
[ax25]
Mar 27 16:33:06 f6bvp-9 kernel:  [<c0254e04>] netif_receive_skb+0x244/0x2e0
Mar 27 16:33:06 f6bvp-9 kernel:  [<c0257975>] process_backlog+0x75/0xe0
Mar 27 16:33:06 f6bvp-9 kernel:  [<c025748b>] net_rx_action+0x12b/0x1d0
Mar 27 16:33:06 f6bvp-9 kernel:  [<c011d5c5>] __do_softirq+0x55/0xc0
Mar 27 16:33:06 f6bvp-9 kernel:  [<c011d677>] do_softirq+0x47/0x50
Mar 27 16:33:06 f6bvp-9 kernel:  [<c011da25>] local_bh_enable_ip+0x95/0xe0
Mar 27 16:33:06 f6bvp-9 kernel:  [<c02bad05>] _spin_unlock_bh+0x25/0x30
Mar 27 16:33:06 f6bvp-9 kernel:  [<c8cbf6b0>]
mkiss_receive_buf+0x360/0x420 [mkiss]
Mar 27 16:33:06 f6bvp-9 kernel:  [<c020e097>] pty_write+0x47/0x60
Mar 27 16:33:06 f6bvp-9 kernel:  [<c020b662>] write_chan+0x222/0x330
Mar 27 16:33:06 f6bvp-9 kernel:  [<c0208d26>] tty_write+0x126/0x1b0
Mar 27 16:33:06 f6bvp-9 kernel:  [<c017298f>] vfs_write+0xaf/0x120
Mar 27 16:33:06 f6bvp-9 kernel:  [<c0172edd>] sys_write+0x3d/0x70
Mar 27 16:33:06 f6bvp-9 kernel:  [<c010412a>] sysenter_past_esp+0x5f/0xa5
Mar 27 16:33:06 f6bvp-9 kernel:  =======================
Mar 27 16:33:07 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77989c8,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 16:33:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 16:33:27 f6bvp-9 last message repeated 3 times
Mar 27 16:34:06 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77991e0,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 16:34:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:35:27 f6bvp-9 last message repeated 2 times
Mar 27 16:35:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:36:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 16:37:27 f6bvp-9 last message repeated 2 times
Mar 27 16:37:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 16:38:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:38:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:39:01 f6bvp-9 crond[4300]: (root) CMD ([ -d /var/lib/php ] &&
find /var/lib/php/ -type f -mmin +$(/usr/lib/php/maxlifetime) -print0 |
xargs -r -0 rm)
Mar 27 16:39:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:39:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:40:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0



Regards,


Bernard P.


