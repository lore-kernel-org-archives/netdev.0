From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: WARN with 3c905 boomerang NIC
Date: Mon, 30 Aug 2010 11:48:05 -0700
Message-ID: <20100830184805.GI2420@linux.vnet.ibm.com>
References: <4C70C516.5020404@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Doug Nazar <nazard.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:52984 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733Ab0H3SsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 14:48:09 -0400
Content-Disposition: inline
In-Reply-To: <4C70C516.5020404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 22, 2010 at 02:35:02AM -0400, Doug Nazar wrote:
>  Since de85d99eb7b595f6751550184b94c1e2f74a828b (netpoll: Fix RCU
> usage) I've been getting the follow warning:

This one is on my list, thank you for checking!

							Thanx, Paul

> Aug 20 22:33:26 dryad kernel: [   64.263065] ------------[ cut here
> ]------------
> Aug 20 22:33:26 dryad kernel: [   64.263089] WARNING: at
> /usr/src/linux/kernel/softirq.c:143 local_bh_enable+0x58/0x82()
> Aug 20 22:33:26 dryad kernel: [   64.263095] Hardware name: OptiPlex GX240
> Aug 20 22:33:26 dryad kernel: [   64.263099] Modules linked in:
> rpcsec_gss_krb5 softdog snd_intel8x0 snd_ac97_codec 8250_pnp ac97_bu
> Aug 20 22:33:26 dryad kernel: [   64.263234] Pid: 5892, comm:
> runscript.sh Not tainted 2.6.36-rc1-00133-g47ade1d #43
> Aug 20 22:33:26 dryad kernel: [   64.263238] Call Trace:
> Aug 20 22:33:26 dryad kernel: [   64.263251]  [<c12a492e>] ?
> printk+0x18/0x1a
> Aug 20 22:33:26 dryad kernel: [   64.263263]  [<c102a015>]
> warn_slowpath_common+0x67/0x8e
> Aug 20 22:33:26 dryad kernel: [   64.263271]  [<c102ee76>] ?
> local_bh_enable+0x58/0x82
> Aug 20 22:33:26 dryad kernel: [   64.263277]  [<c102ee76>] ?
> local_bh_enable+0x58/0x82
> Aug 20 22:33:26 dryad kernel: [   64.263285]  [<c102a059>]
> warn_slowpath_null+0x1d/0x1f
> Aug 20 22:33:26 dryad kernel: [   64.263292]  [<c102ee76>]
> local_bh_enable+0x58/0x82
> Aug 20 22:33:26 dryad kernel: [   64.263301]  [<c12399e5>]
> netif_rx+0x14f/0x172
> Aug 20 22:33:26 dryad kernel: [   64.263315]  [<e20e8f0f>]
> boomerang_rx+0x27a/0x42f [3c59x]
> Aug 20 22:33:26 dryad kernel: [   64.263328]  [<c10a369b>] ?
> path_put+0x20/0x23
> Aug 20 22:33:26 dryad kernel: [   64.263342]  [<e20eadfb>]
> boomerang_interrupt+0xd9/0x2b7 [3c59x]
> Aug 20 22:33:26 dryad kernel: [   64.263361]  [<c105651c>]
> handle_IRQ_event+0x3e/0x13e
> Aug 20 22:33:26 dryad kernel: [   64.263369]  [<c1057c6e>]
> handle_fasteoi_irq+0x3c/0x89
> Aug 20 22:33:26 dryad kernel: [   64.263378]  [<c1004e58>]
> handle_irq+0x18/0x30
> Aug 20 22:33:26 dryad kernel: [   64.263385]  [<c10048cb>] do_IRQ+0x34/0x97
> Aug 20 22:33:26 dryad kernel: [   64.263392]  [<c10037a9>]
> common_interrupt+0x29/0x30
> Aug 20 22:33:26 dryad kernel: [   64.263398] ---[ end trace
> 511646352388ce9c ]---
> 
> The card is an:
> 02:0c.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M
> [Tornado] (rev 78)
> 
> Doug
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
