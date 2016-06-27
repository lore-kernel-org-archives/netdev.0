From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 27 Jun 2016 06:52:29 +0200
Message-ID: <1467003149.6850.142.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160627114623.2c985be5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160627114623.2c985be5@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-06-27 at 11:46 +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/sched/sch_netem.c
> 
> between commit:
> 
>   21de12ee5568 ("netem: fix a use after free")
> 
> from the net tree and commit:
> 
>   520ac30f4551 ("net_sched: drop packets after root qdisc lock is released")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.
> 

Looks good, although the 'use after free' does not happen anymore on
net-next since we defer skb freeing.

I spotted the bug in stable tree when cooking the net-next patch
actually ;)

Thanks.
