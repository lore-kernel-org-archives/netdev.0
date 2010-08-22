From: David Miller <davem@davemloft.net>
Subject: Re: WARN with 3c905 boomerang NIC
Date: Sun, 22 Aug 2010 00:46:49 -0700 (PDT)
Message-ID: <20100822.004649.115913406.davem@davemloft.net>
References: <4C70C516.5020404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: nazard.lkml@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C70C516.5020404@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Nazar <nazard.lkml@gmail.com>
Date: Sun, 22 Aug 2010 02:35:02 -0400

>  Since de85d99eb7b595f6751550184b94c1e2f74a828b (netpoll: Fix RCU
>  usage) I've been getting the follow warning:
> Aug 20 22:33:26 dryad kernel: [ 64.263065] ------------[ cut here
> ]------------
> Aug 20 22:33:26 dryad kernel: [ 64.263089] WARNING: at
> /usr/src/linux/kernel/softirq.c:143 local_bh_enable+0x58/0x82()
> Aug 20 22:33:26 dryad kernel: [ 64.263095] Hardware name: OptiPlex
> GX240
> Aug 20 22:33:26 dryad kernel: [ 64.263099] Modules linked in:
> rpcsec_gss_krb5 softdog snd_intel8x0 snd_ac97_codec 8250_pnp ac97_bu
> Aug 20 22:33:26 dryad kernel: [ 64.263234] Pid: 5892, comm:
> runscript.sh Not tainted 2.6.36-rc1-00133-g47ade1d #43
> Aug 20 22:33:26 dryad kernel: [   64.263238] Call Trace:
> Aug 20 22:33:26 dryad kernel: [ 64.263251] [<c12a492e>] ?
> printk+0x18/0x1a
> Aug 20 22:33:26 dryad kernel: [ 64.263263] [<c102a015>]
> warn_slowpath_common+0x67/0x8e
> Aug 20 22:33:26 dryad kernel: [ 64.263271] [<c102ee76>] ?
> local_bh_enable+0x58/0x82
> Aug 20 22:33:26 dryad kernel: [ 64.263277] [<c102ee76>] ?
> local_bh_enable+0x58/0x82
> Aug 20 22:33:26 dryad kernel: [ 64.263285] [<c102a059>]
> warn_slowpath_null+0x1d/0x1f
> Aug 20 22:33:26 dryad kernel: [ 64.263292] [<c102ee76>]
> local_bh_enable+0x58/0x82
> Aug 20 22:33:26 dryad kernel: [ 64.263301] [<c12399e5>]
> netif_rx+0x14f/0x172
> Aug 20 22:33:26 dryad kernel: [ 64.263315] [<e20e8f0f>]
> boomerang_rx+0x27a/0x42f [3c59x]
 ...

Yes we know about this and are working on a solution.
