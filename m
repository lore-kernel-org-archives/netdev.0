From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Wed, 17 Nov 2004 07:39:42 +1100
Message-ID: <E1CUA74-0002hr-00@gondolin.me.apana.org.au>
References: <20041116104755.32bdb7a7.davem@davemloft.net>
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20041116104755.32bdb7a7.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
>
>> KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
>> KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (152)
>> 
>> looks like an issue with the accounting of sk_forward_alloc with non-default
>> values of tcp_tso_win_divisor.
> 
> The issue is if you change the value while there are still existing
> sockets which used a previous value at least once.

Could you elaborate the code path that you've spotted that causes this
when the divisor is changed?

Perhaps we're not caching the MSS value everywhere where we should be?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
