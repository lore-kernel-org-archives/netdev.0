From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Outreachy kernel] [PATCH] net: ipv6: netfilter: Format block
 comments.
Date: Fri, 7 Apr 2017 18:15:07 +0200
Message-ID: <20170407161507.GA9367@salvia>
References: <20170329083943.GA23844@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329083943.GA23844@arushi-HP-Pavilion-Notebook>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 02:09:43PM +0530, Arushi Singhal wrote:
> Fix checkpatch warnings:
> WARNING: Block comments use a trailing */ on a separate line
> WARNING: Block comments use * on subsequent lines
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
>  net/ipv6/netfilter/ip6_tables.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
> index b8cb61c27aa1..ac69ce3bfa1e 100644
> --- a/net/ipv6/netfilter/ip6_tables.c
> +++ b/net/ipv6/netfilter/ip6_tables.c
> @@ -51,14 +51,14 @@ void *ip6t_alloc_initial_table(const struct xt_table *info)
>  }
>  EXPORT_SYMBOL_GPL(ip6t_alloc_initial_table);
>  
> -/*
> -   We keep a set of rules for each CPU, so we can avoid write-locking
> -   them in the softirq when updating the counters and therefore
> -   only need to read-lock in the softirq; doing a write_lock_bh() in user
> -   context stops packets coming through and allows user context to read
> -   the counters or update the rules.
> -
> -   Hence the start of any table is given by get_table() below.  */
> +/* We keep a set of rules for each CPU, so we can avoid write-locking
> + * them in the softirq when updating the counters and therefore
> + * only need to read-lock in the softirq; doing a write_lock_bh() in user
> + * context stops packets coming through and allows user context to read
> + * the counters or update the rules.
> + *
> + * Hence the start of any table is given by get_table() below.
> + */

This comment is obsolete and should go.

We have no set of rules per CPU anymore.
