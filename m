From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Sat, 30 Oct 2004 11:48:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CNiLo-0008Fj-00@gondolin.me.apana.org.au>
References: <20041029215134.GA15414@lists.us.dell.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt_Domsch@dell.com (Matt Domsch)
In-Reply-To: <20041029215134.GA15414@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Domsch <Matt_Domsch@dell.com> wrote:
> If dev->dev_addr is zero, then the memcpy() never takes place, and the

Huh? You mean dev->addr_len? Surely the caller has to know what the
address length is to use this anyway, no?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
