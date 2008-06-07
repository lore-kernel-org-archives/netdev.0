From: Phil Oester <kernel@linuxace.com>
Subject: Re: bug report
Date: Sat, 7 Jun 2008 08:09:48 -0700
Message-ID: <20080607150948.GA4690@linuxace.com>
References: <48499731.1080807@gmail.com> <6101e8c40806061844g5b7676d4xb48c5c69ad48391f@mail.gmail.com> <20080606225643.8be222a9.akpm@linux-foundation.org> <Pine.LNX.4.64.0806071141480.24862@wrl-59.cs.helsinki.fi> <6101e8c40806070550h62866816s1d8f8c1ba31f59f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>, zsirmo@zsirmo.hu,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Brian Vowell <brian.vowell@gmail.com>
To: Oliver Pinter <oliver.pntr@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761890AbYFGPKF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6101e8c40806070550h62866816s1d8f8c1ba31f59f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 07, 2008 at 02:50:06PM +0200, Oliver Pinter wrote:
> [snip]
> Jun  6 14:04:11 www kernel: [ 6464.556309] clamscan: page allocation
> failure. order:3, mode:0x4020 <------------- this

"Me too".  Lots of order 3 allocation failures on e1000 nics
since upgrading some heavy traffic boxes to 2.6.25 (though from 2.6.21,
so unclear on when it began).

Phil

Jun  2 11:11:24 px01 kernel: swapper: page allocation failure. order:3, mode:0x4020
Jun  2 11:11:24 px01 kernel: Pid: 0, comm: swapper Not tainted 2.6.25.2-x86_64.1 #1
Jun  2 11:11:24 px01 kernel: 
Jun  2 11:11:24 px01 kernel: Call Trace:
Jun  2 11:11:24 px01 kernel:  <IRQ>  [<ffffffff8024ce51>] __alloc_pages+0x2dd/0x2f6
Jun  2 11:11:24 px01 kernel:  [<ffffffff8026578d>] __slab_alloc+0x16e/0x4f9
Jun  2 11:11:24 px01 kernel:  [<ffffffff80394e84>] tcp_collapse+0x164/0x394
Jun  2 11:11:25 px01 kernel:  [<ffffffff802656d0>] __slab_alloc+0xb1/0x4f9
Jun  2 11:11:25 px01 kernel:  [<ffffffff80394e84>] tcp_collapse+0x164/0x394
Jun  2 11:11:25 px01 kernel:  [<ffffffff8026685d>] __kmalloc_track_caller+0x82/0xb8
Jun  2 11:11:25 px01 kernel:  [<ffffffff8036a124>] __alloc_skb+0x5b/0x121
Jun  2 11:11:25 px01 kernel:  [<ffffffff80394e84>] tcp_collapse+0x164/0x394
Jun  2 11:11:25 px01 kernel:  [<ffffffff80395261>] tcp_prune_queue+0x1ad/0x21e
Jun  2 11:11:25 px01 kernel:  [<ffffffff803954ba>] tcp_data_queue+0x1e8/0xbab
Jun  2 11:11:25 px01 kernel:  [<ffffffff803974e8>] tcp_rcv_established+0x64c/0x6fc
Jun  2 11:11:25 px01 kernel:  [<ffffffff8039c76f>] tcp_v4_do_rcv+0x2c/0x1b4
Jun  2 11:11:25 px01 kernel:  [<ffffffff8039e43e>] tcp_v4_rcv+0x6b3/0x705
Jun  2 11:11:25 px01 kernel:  [<ffffffff80384cdc>] ip_local_deliver_finish+0xf6/0x1b3
Jun  2 11:11:25 px01 kernel:  [<ffffffff80384bc3>] ip_rcv_finish+0x2bf/0x2e2
Jun  2 11:11:25 px01 kernel:  [<ffffffff8023ada3>] getnstimeofday+0x2f/0x83
Jun  2 11:11:25 px01 kernel:  [<ffffffff8036e6b2>] netif_receive_skb+0x1af/0x21b
Jun  2 11:11:25 px01 kernel:  [<ffffffff8032da6d>] e1000_clean_rx_irq+0x3f3/0x4e7
