From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 17:00:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831070043.GA320@gondor.apana.org.au>
References: <20040830191915.04d49268.davem@davemloft.net> <E1C1yRs-00086x-00@gondolin.me.apana.org.au> <20040830223920.1db0d5ae.davem@davemloft.net> <20040831064337.GA32614@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@netfilter.org, netfilter-devel@lists.netfilter.org,
        rusty@rustcorp.com.au, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040831064337.GA32614@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 04:43:37PM +1000, herbert wrote:
> 
> In this case I really don't see what's wrong with setting oif in
> the key.  In fact that's exactly what we want to do: Get the
> preferred source address when the localhost is going to send
> a packet to *that* device.

Here's a better idea.  Why don't we forget about the route lookup
and call inet_select_addr directly?

The only time when someone wants to use MASQUERADE over SNAT is
when the interface carries a dynamic address.  In such cases,
inet_select_addr should always return the preferred address, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
