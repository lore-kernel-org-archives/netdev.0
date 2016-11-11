From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about xt_find_table_lock
Date: Fri, 11 Nov 2016 12:58:27 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1611111257540.2074@hadrien>
References: <alpine.DEB.2.20.1611111141380.2074@hadrien> <20161111112307.GA7274@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Julia Lawall <julia.lawall@lip6.fr>, pablo@netfilter.org,
        kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        christophe.jaillet@wanadoo.fr
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161111112307.GA7274@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 11 Nov 2016, Florian Westphal wrote:

> Julia Lawall <julia.lawall@lip6.fr> wrote:
> > The function xt_find_table_lock defined in net/netfilter/x_tables.c is
> > preceeded by a comment that says that it returns ERR_PTR() on error.  But
> > looking at the definition, I only see occurrences of return NULL and
> > returns of pointers that have previously been dereferenced.  Is it the
> > code or the documentation that is incorrect?  The call sites seem to be
> > using IS_ERR_OR_NULL.  Is there a plan to return ERR_PTR values in the
> > future?
>
> It used to return ERR_PTR, see:
>
> commit 7926dbfa4bc14e27f4e18a6184a031a1c1e077dc
> netfilter: don't use mutex_lock_interruptible()
>
> So the comment isn't correct anymore and callers could test vs NULL.

Thanks for the quick feedback.

julia
