From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Tue, 5 Apr 2005 20:39:18 +1000
Message-ID: <20050405103918.GA24863@gondor.apana.org.au>
References: <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au> <20050331212325.5e996432.davem@davemloft.net> <20050402004956.GA24339@gondor.apana.org.au> <20050401172007.7296eced.davem@davemloft.net> <20050402020947.GA24998@gondor.apana.org.au> <42501E51.3000401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42501E51.3000401@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 06:48:17PM +0200, Patrick McHardy wrote:
> 
> Agreed. There is also a bug in my patch, tmpl->daddr can be 0 in which
> case the daddr passed as an argument to xfrm_state_find() will be used.
> My patch only checked tmpl->daddr, this patch fixes it. It also uses

Why not just use daddr? It's always guaranteed to be correct.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
