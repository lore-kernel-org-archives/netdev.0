From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 0/2] constify nf_hook_ops structures
Date: Sat, 29 Jul 2017 10:50:51 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1707291049370.2002@hadrien>
References: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr> <20170729084429.GE28392@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-decnet-user@lists.sourceforge.net, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729084429.GE28392@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 29 Jul 2017, Florian Westphal wrote:

> Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> > The nf_hook_ops structure is only passed as the second argument to
> > nf_register_net_hook or nf_unregister_net_hook, both of which are
> > declared as const.  Thus the nf_hook_ops structure itself can be
> > const.
>
> Right, also see
> http://patchwork.ozlabs.org/patch/793767/
>
> This series misses most of them (all arrays perhaps)?

Yes, my rule doesn't look for arrays.  I guess they are all done already
anyway?

thanks,
julia


> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
