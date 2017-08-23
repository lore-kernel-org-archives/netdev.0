From: Ido Schimmel <idosch@idosch.org>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 23 Aug 2017 08:41:13 +0300
Message-ID: <20170823054113.GA5342@shredder>
References: <20170823113105.0bd692ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Wei Wang <weiwan@google.com>,
        Ido Schimmel <idosch@mellanox.com>,
        iri Pirko <jiri@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170823113105.0bd692ea@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2017 at 11:31:05AM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/ipv6/ip6_fib.c
> 
> between commit:
> 
>   c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")
> 
> from the net tree and commit:
> 
>   a460aa83963b ("ipv6: fib: Add helpers to hold / drop a reference on rt6_info")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good to me.

Thanks!
