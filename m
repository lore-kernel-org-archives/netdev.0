From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Sat, 29 Mar 2008 13:04:16 +0100
Message-ID: <47EE3040.3050208@free.fr>
References: <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:59813 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbYC2MEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2008 08:04:23 -0400
In-Reply-To: <20080328120721.GA11060@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:

> On Wed, Mar 26, 2008 at 07:35:38PM +0100, Jarek Poplawski wrote:
> ...
>> OK, here is the next try. (Apply after all previous patches to any 2.6.24.x;
>> there would be more noise, so revert it after catching some data.)
> 
> Bernard, I fucked it up with this #3: (changed macro to function at
> the last minute). I'm currently reading this, and maybe I'll figure
> out something, but if it's not a big problem for you to repeat this
> after adding this #4 (after all previous) it should be 'a bit' easier.
> (But no need to hurry.)
> 
> Very sorry,
> Jarek P.
> 
> (debugging patch #4)

Please find below an extract of /var/log/messages
The time of interest is around 12:03


  Mar 29 11:52:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a820
  Mar 29 11:52:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f0a820
  Mar 29 11:52:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a820
  Mar 29 11:52:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f0a820
  Mar 29 11:52:59 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c6ae2bc8, 
c0f0a040, 6b6b6b6b, 00000000, 00000000
  Mar 29 11:53:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a580
  Mar 29 11:53:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f0a580
  Mar 29 11:53:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a580
  Mar 29 11:53:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f0a580
  Mar 29 11:54:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a580
  Mar 29 11:54:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f0a580
  Mar 29 11:54:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a580
  Mar 29 11:54:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f0a580
  Mar 29 11:55:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:55:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:55:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:55:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:56:52 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:56:52 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:56:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:56:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:56:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:56:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:56:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:56:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:57:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:57:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:57:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:57:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:58:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:58:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:58:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:58:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:59:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:59:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 11:59:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 11:59:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 12:00:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d58040
  Mar 29 12:00:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d58040
  Mar 29 12:00:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d58040
  Mar 29 12:00:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d58040
  Mar 29 12:01:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d58040
  Mar 29 12:01:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d58040
  Mar 29 12:01:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d58040
  Mar 29 12:01:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d58040
  Mar 29 12:02:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 12:02:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 12:02:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f60820
  Mar 29 12:02:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0f60820
  Mar 29 12:03:07 f6bvp-9 kernel: AX25: ax25_kick, 279, c65e43f0, 
c0d58040, 6b6b6b6b, 00000000, 00000000
  Mar 29 12:03:07 f6bvp-9 kernel: sk_ax25_debug = 0, 11, 0, 5, c0d58040, 
6b6b6b6b, c65e43f0
  Mar 29 12:03:07 f6bvp-9 kernel: WARNING: at net/core/sock.c:1561 
sock_def_write_space()
  Mar 29 12:03:07 f6bvp-9 kernel: Pid: 3447, comm: mkiss Not tainted 
2.6.24.4 #6
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c010513a>] show_trace_log_lvl+0x1a/0x30
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0105b52>] show_trace+0x12/0x20
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c01064ac>] dump_stack+0x6c/0x80
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c024d68b>] 
sock_def_write_space+0x17b/0x190
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c024da7a>] sock_wfree+0x3a/0x40
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c024fc3d>] skb_release_all+0x4d/0xf0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c024f3eb>] __kfree_skb+0xb/0x90
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c024f489>] kfree_skb+0x19/0x30
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c6ae37>] ax_xmit+0xf7/0x360 [mkiss]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0255497>] 
dev_hard_start_xmit+0x207/0x270
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0265924>] __qdisc_run+0x54/0x1a0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0257cdc>] dev_queue_xmit+0x25c/0x330
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c77a77>] 
ax25_queue_xmit+0x47/0x70 [ax25]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c77b65>] 
ax25_transmit_buffer+0xc5/0x110 [ax25]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c77c2d>] 
ax25_send_iframe+0x7d/0x110 [ax25]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c77d70>] ax25_kick+0xb0/0x2a0 [ax25]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c790a9>] 
ax25_std_frame_in+0x69/0x890 [ax25]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c76dba>] 
ax25_kiss_rcv+0x2ba/0x7b0 [ax25]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0254df4>] 
netif_receive_skb+0x244/0x2e0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0257965>] process_backlog+0x75/0xe0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c025747b>] net_rx_action+0x12b/0x1d0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c011d5c5>] __do_softirq+0x55/0xc0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c011d677>] do_softirq+0x47/0x50
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c011da25>] local_bh_enable_ip+0x95/0xe0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c02bace5>] _spin_unlock_bh+0x25/0x30
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c8c6a6b0>] 
mkiss_receive_buf+0x360/0x420 [mkiss]
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c020e097>] pty_write+0x47/0x60
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c020b662>] write_chan+0x222/0x330
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0208d26>] tty_write+0x126/0x1b0
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c017298f>] vfs_write+0xaf/0x120
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c0172edd>] sys_write+0x3d/0x70
  Mar 29 12:03:07 f6bvp-9 kernel:  [<c010412a>] sysenter_past_esp+0x5f/0xa5
  Mar 29 12:03:07 f6bvp-9 kernel:  =======================
  Mar 29 12:03:52 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:03:52 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:03:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:03:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:03:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:03:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:03:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:03:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:04:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:04:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:04:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:04:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:05:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:05:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:05:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:05:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:06:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:06:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:06:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:06:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:07:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:07:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:07:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:07:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:08:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:08:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:08:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:08:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:09:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:09:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:09:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d58040
  Mar 29 12:09:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d58040
  Mar 29 12:10:52 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:10:52 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:10:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:10:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:10:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:10:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:10:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:10:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:11:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:11:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:11:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c64f5a90, c0d582e0
  Mar 29 12:11:53 f6bvp-9 kernel: AX25- ax25_release, 959, c64f5a90, 
c0d582e0
  Mar 29 12:11:59 f6bvp-9 netromd[3557]: netromr: SIOCADDRT: Invalid 
argument
  Mar 29 12:12:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d582e0
  Mar 29 12:12:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d582e0
  Mar 29 12:12:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d582e0
  Mar 29 12:12:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d582e0
  Mar 29 12:12:55 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c65e4c08, 
c0d58040, 6b6b6b6b, 00000000, 00000000
  Mar 29 12:12:57 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c7ba74a0, 
c0d582e0, 6b6b6b6b, 00000000, 00000000
  Mar 29 12:13:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0d582e0
  Mar 29 12:13:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0, 
c0d582e0

Regards,

Bernard P.

