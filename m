From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops: Process zebra, EIP is at fib_create_info+0x22b/0x580
Date: Sun, 22 Aug 2004 18:06:46 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BynNG-0007qB-00@gondolin.me.apana.org.au>
References: <20040821221751.547feefe.davem@redhat.com>
Cc: vrsbs@derbian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20040821221751.547feefe.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> wrote:
> On Sun, 22 Aug 2004 00:04:17 +0300
> Joonas Kortesalmi <vrsbs@derbian.org> wrote:
> 
>> Running 2.6.8.1 and got a nice Oops from zebra (quagga).
> 
> Can you figure out where exactly this OOPS is in fib_create_info()?

This is very similar to the report in the message titled
"2.6.8 + sargs = pb" where fib_info_list was corrupted.

In fact, the corrupted fib_next value here is exactly the same as
the other report.  Not only that, the value appears to be a valid i386
instruction possibly coming from somewhere else in net/ipv4 code.

Do you know of any changes between 2.6.7 and 2.6.8 that might impact
on the FIB stuff? Any locking changes?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
