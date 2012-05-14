From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/6] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 14 May 2012 16:22:49 +0200
Message-ID: <20120514142249.GA9778@breakpoint.cc>
References: <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F0A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0A@saturn3.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> wrote:
>  
> > NFPROTO_* constants were usually equal to PF_* constants but it is not
> > necessary and it will waste less memory if we don't do so 
> > (see commit 7e9c6e
> > "netfilter: Introduce NFPROTO_* constants")
> ...
> >  
> >  static struct nf_hook_ops dnrmg_ops __read_mostly = {
> >  	.hook		= dnrmg_hook,
> > -	.pf		= PF_DECnet,
> > +	.pf		= NFPROTO_DECNET,
> >  	.hooknum	= NF_DN_ROUTE,
> >  	.priority	= NF_DN_PRI_DNRTMSG,
> >  };
> 
> Might it be worth renaming the .pf member to (say) .nfproto
> to help avoid confusion?

NFPROTO_* values are exported to userspace, so I don't think
its safe to change these values.
