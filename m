From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Sat, 30 Oct 2004 11:51:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CNiOT-0008GU-00@gondolin.me.apana.org.au>
References: <20041030013700.GA21540@lists.us.dell.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt_Domsch@dell.com (Matt Domsch)
In-Reply-To: <20041030013700.GA21540@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Domsch <Matt_Domsch@dell.com> wrote:
> 
> s/dev_addr/addr_len in the comments above, that's the field we care
> about being non-zero.

This still doesn't make sense.  What if dev->addr_len is less than the
size of the buffer? The caller has to know what the length is anyway.

BTW, the ioctl interface is obsolete.  Please use the rtnetlink
interface where dev->addr_len can be read properly.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
