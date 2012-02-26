From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: WARNING: at net/ipv4/tcp_input.c:3418
Date: Sat, 25 Feb 2012 16:06:40 -0800
Message-ID: <CAGK4HS8Wrj0c9qo66F8oBkGA4PR28z2Vsf4J3_4=KGq989wYng@mail.gmail.com>
References: <20120225183445.GB5661@x4>
	<CAGK4HS8bSF3y45Jgf3Vc0L1mGXt_vx1M2rDJoU8jPV6ZY8Dacw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell <ncardwell@google.com>, ilpo.jarvinen@helsinki.fi
To: netdev <netdev@vger.kernel.org>,
	Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52933 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab2BZAGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 19:06:41 -0500
Received: by vbbff1 with SMTP id ff1so202115vbb.19
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2012 16:06:40 -0800 (PST)
In-Reply-To: <CAGK4HS8bSF3y45Jgf3Vc0L1mGXt_vx1M2rDJoU8jPV6ZY8Dacw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending this mail because of earlier failure...


On 25 February 2012 10:34, Markus Trippelsdorf <markus@trippelsdorf.de>=
 wrote:
>
> I've hit the following warnings today while using bittorrent:
>
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
> Hardware name: System Product Name
> Pid: 14513, comm: cc1plus Not tainted 3.3.0-rc4-00091-gbb4c7e9-dirty =
#3
> Call Trace:
> =A0<IRQ> =A0[<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
> =A0[<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
> =A0[<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
> =A0[<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
> =A0[<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
> =A0[<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
> =A0[<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
> =A0[<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
> =A0[<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
> =A0[<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
> =A0[<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
> =A0[<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
> =A0[<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
> =A0[<ffffffff8147928c>] ? call_softirq+0x1c/0x26
> =A0[<ffffffff810341bd>] ? do_softirq+0x3d/0x80
> =A0[<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
> =A0[<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
> =A0[<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
> =A0<EOI>
> ---[ end trace 6bd1602ca76fa623 ]---
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xe=
e0()
> Hardware name: System Product Name
> Pid: 14513, comm: cc1plus Tainted: G =A0 =A0 =A0 =A0W =A0 =A03.3.0-rc=
4-00091-gbb4c7e9-dirty #3
> Call Trace:
> =A0<IRQ> =A0[<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
> =A0[<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
> =A0[<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
> =A0[<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
> =A0[<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
> =A0[<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
> =A0[<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
> =A0[<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
> =A0[<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
> =A0[<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
> =A0[<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
> =A0[<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
> =A0[<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
> =A0[<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
> =A0[<ffffffff8147928c>] ? call_softirq+0x1c/0x26
> =A0[<ffffffff810341bd>] ? do_softirq+0x3d/0x80
> =A0[<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
> =A0[<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
> =A0[<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
> =A0<EOI>
> ---[ end trace 6bd1602ca76fa624 ]---
>

=A0Hi Markus,
This looks similar to the errors that were reported in the following th=
reads
http://lists.openwall.net/netdev/2012/02/06/13
http://lists.openwall.net/netdev/2012/02/06/23

Maybe you are hitting the same bug. It was hoped in the discussion
that the following commit would fix it but looks like it does not
(assuming it is the same bug). From your kernel version =A0(3.3.0-rc4),
it looks like you should have this commit. So, maybe it did not fix
this bug.


commit 5b35e1e6e9ca651e6b291c96d1106043c9af314a
Author: Neal Cardwell <ncardwell@google.com>
Date: =A0 Sat Jan 28 17:29:46 2012 +0000

=A0 =A0tcp: fix tcp_trim_head() to adjust segment count with skb MSS


CCing Neal and Ilpo.

Regards,
Vijay
