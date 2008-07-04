From: "Alexander Beregalov" <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2213
Date: Fri, 4 Jul 2008 22:55:18 +0400
Message-ID: <a4423d670807041155o7629b3d7ie3323d79a9ea7301@mail.gmail.com>
References: <a4423d670806041450h17a2d3b1w40ea9ff8550a4b11@mail.gmail.com>
	 <20080604.145244.07802877.davem@davemloft.net>
	 <a4423d670806041529q6911f68fq68ee9ed8f8f50139@mail.gmail.com>
	 <Pine.LNX.4.64.0806061509530.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "=?UTF-8?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0806061509530.16829-x/A8LOkYjdVsRR2hCrRKtT03IgOmwywn@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It looks similar.

WARNING: at net/ipv4/tcp_input.c:2213 tcp_mark_head_lost+0x15c/0x164()
Modules linked in: i2c_nforce2
Pid: 0, comm: swapper Not tainted 2.6.26-rc8-00089-ge1441b9-dirty #1
 [<c0119f15>] warn_on_slowpath+0x41/0x7b
 [<c01348dc>] ? mark_held_locks+0x4e/0x66
 [<c011e518>] ? local_bh_enable+0xcf/0xe6
 [<c0134a50>] ? trace_hardirqs_on+0xd0/0x10d
 [<c031f8c5>] ? dev_queue_xmit+0x2cd/0x300
 [<c0336968>] ? ip_finish_output+0x20c/0x244
 [<c0336a06>] ? ip_output+0x66/0x6a
 [<c0135b9e>] ? __lock_acquire+0xc26/0xc35
 [<c033e5e1>] tcp_mark_head_lost+0x15c/0x164
 [<c034064c>] tcp_ack+0x14ff/0x1760
 [<c0342ffa>] tcp_rcv_established+0xdc/0x96a
 [<c0348807>] tcp_v4_do_rcv+0x25/0x14e
 [<c0383159>] ? _spin_lock_nested+0x4f/0x57
 [<c0348c2a>] tcp_v4_rcv+0x2fa/0x492
 [<c0332b42>] ip_local_deliver+0x7d/0xcd
 [<c0332a9e>] ip_rcv+0x352/0x379
 [<c012c918>] ? ktime_get_real+0x13/0x2f
 [<c031eecb>] netif_receive_skb+0x1ec/0x21a
 [<c032a9d4>] ? eth_type_trans+0x28/0xc7
 [<c02e3a2e>] nv_napi_poll+0x1fa/0x618
 [<c0134a50>] ? trace_hardirqs_on+0xd0/0x10d
 [<c031df80>] net_rx_action+0x8b/0x14e
 [<c011e60b>] __do_softirq+0x54/0xa1
 [<c013fc13>] ? handle_fasteoi_irq+0x0/0xab
 [<c010494f>] do_softirq+0x57/0xa6
 [<c011e201>] irq_exit+0x3b/0x7c
 [<c0104b18>] do_IRQ+0xca/0xe2
 [<c0101d2a>] ? default_idle+0x0/0x4e
 [<c0101d2a>] ? default_idle+0x0/0x4e
 [<c0103712>] common_interrupt+0x2e/0x34
 [<c0101d2a>] ? default_idle+0x0/0x4e
 [<c0101d2a>] ? default_idle+0x0/0x4e
 [<c0101d57>] ? default_idle+0x2d/0x4e
 [<c0101cfd>] cpu_idle+0x62/0x8f
 [<c0375c81>] rest_init+0x61/0x63
 =======================
---[ end trace 458274215148af5e ]---


You are right, I have no idea how to reproduce it.
I have two events, once per  month.
