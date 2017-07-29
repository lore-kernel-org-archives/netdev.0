From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/2] constify nf_hook_ops structures
Date: Sat, 29 Jul 2017 11:16:18 +0200
Message-ID: <20170729091618.GF28392@breakpoint.cc>
References: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr>
 <20170729084429.GE28392@breakpoint.cc>
 <alpine.DEB.2.20.1707291049370.2002@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        linux-decnet-user@lists.sourceforge.net, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1707291049370.2002@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia.lawall@lip6.fr> wrote:
> 
> 
> On Sat, 29 Jul 2017, Florian Westphal wrote:
> 
> > Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> > > The nf_hook_ops structure is only passed as the second argument to
> > > nf_register_net_hook or nf_unregister_net_hook, both of which are
> > > declared as const.  Thus the nf_hook_ops structure itself can be
> > > const.
> >
> > Right, also see
> > http://patchwork.ozlabs.org/patch/793767/
> >
> > This series misses most of them (all arrays perhaps)?
> 
> Yes, my rule doesn't look for arrays.  I guess they are all done already
> anyway?

I think so (the patch is not yet applied though).

>From a quick glance I don't see why we can't e.g. constify
nf_conntrack_l3/4_proto too. It is not going to be as simple
as just placing const everywhere, but I see no requirement for
having these writeable.
