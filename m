From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: fixed typo of reassembly.c
Date: Sat, 02 Oct 2004 15:02:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CDc2I-0003wP-00@gondolin.me.apana.org.au>
References: <20041001151923.261b42b3.davem@davemloft.net>
Cc: yasuyuki.kozakai@toshiba.co.jp, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20041001151923.261b42b3.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> It is textual fix only, do you realize this?
> Both ntohs() and htons() perform the same transformation
> on a 16-bit data item.  It really does not matter which
> one you actually use, in practice.

It might make a difference in future if the sparse people decide to
annotate its arguments/return values.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
