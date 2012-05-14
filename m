From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/6] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 14 May 2012 16:38:45 +0200
Message-ID: <20120514143845.GC12992@1984>
References: <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F0A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
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

On Mon, May 14, 2012 at 03:18:16PM +0100, David Laight wrote:
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

That can be done follow-up patch, I guess.
