From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: WARN with 3c905 boomerang NIC
Date: Thu, 26 Aug 2010 20:32:08 +0200
Message-ID: <201008262032.08815.maciej.rutecki@gmail.com>
References: <4C70C516.5020404@gmail.com>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Doug Nazar <nazard.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49313 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534Ab0HZScN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 14:32:13 -0400
In-Reply-To: <4C70C516.5020404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On niedziela, 22 sierpnia 2010 o 08:35:02 Doug Nazar wrote:
>   Since de85d99eb7b595f6751550184b94c1e2f74a828b (netpoll: Fix RCU
> usage) I've been getting the follow warning:
> 
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
> 02:0c.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado]
> (rev 78)
> 

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=17131
for your bug report, please add your address to the CC list in there, thanks!
-- 
Maciej Rutecki
http://www.maciek.unixy.pl
