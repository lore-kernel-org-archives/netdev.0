From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/4] ipv6: add a new namespace for nf_conntrack_reasm
Date: Tue, 18 Sep 2012 18:44:01 +0800
Message-ID: <1347965041.14402.28.camel@cr0>
References: <1347942582-23962-1-git-send-email-amwang@redhat.com>
	 <1347942582-23962-2-git-send-email-amwang@redhat.com>
	 <20120918073756.GA18206@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120918073756.GA18206@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-09-18 at 09:37 +0200, Pablo Neira Ayuso wrote:
> > +#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
> > +	struct netns_nf_ct	nf_ct;
> > +#endif
> 
> There's above one "struct netns_ct" that already encapsulates
> netfilter conntrack netns parameters.
> 
> However, I'd prefer if, while at it, you define some struct
> netns_nf_frag instead.
> 
> In net/ipv6/netfilter/Makefile, it says:
> 
> # defrag
> nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
> 
> Note that nf defragmentation is not glued to conntrack anymore. So I'd
> go for one netns_nf_frag for this in include/net/net_namespace.h
> 

Sure, I will rename that struct to 'struct netns_nf_frag'.

Thanks for review!


