From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/4] ipv6: fix the reassembly expire code
 in nf_conntrack
Date: Wed, 19 Sep 2012 17:28:35 -0400 (EDT)
Message-ID: <20120919.172835.698305064973980053.davem@davemloft.net>
References: <1348023011-16195-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au, pablo@netfilter.org
To: amwang@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348023011-16195-1-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Wed, 19 Sep 2012 10:50:07 +0800

> V4: some coding style fix
> 
> V3: rename struct netns_nf_ct to struct netns_nf_frag
> 
> V2: use IS_ENABLED(CONFIG_IPV6) to fix a build error
>     rebase to latest net-next
> 
> ipv6: add a new namespace for nf_conntrack_reasm
> ipv6: unify conntrack reassembly expire code with standard one
> ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static
> ipv6: unify fragment thresh handling code
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Cong Wang <amwang@redhat.com>

All applied to net-next, thanks.
