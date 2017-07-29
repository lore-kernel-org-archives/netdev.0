From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/2] constify nf_hook_ops structures
Date: Sat, 29 Jul 2017 10:44:29 +0200
Message-ID: <20170729084429.GE28392@breakpoint.cc>
References: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-decnet-user@lists.sourceforge.net, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> The nf_hook_ops structure is only passed as the second argument to
> nf_register_net_hook or nf_unregister_net_hook, both of which are
> declared as const.  Thus the nf_hook_ops structure itself can be
> const.

Right, also see
http://patchwork.ozlabs.org/patch/793767/

This series misses most of them (all arrays perhaps)?
