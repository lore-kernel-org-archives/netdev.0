From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sat, 26 Mar 2005 13:32:02 +1100
Message-ID: <E1DF15m-0006JT-00@gondolin.me.apana.org.au>
References: <1111799460.1089.785.camel@jzny.localdomain>
Cc: herbert@gondor.apana.org.au, davem@redhat.com, nakam@linux-ipv6.org,
        shinta.sugimoto@ericsson.com, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1111799460.1089.785.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
> 
> What i have seen being described is as follows:
> 
> user space app --> kernel
>  acquire with all necessary parameters
> kernel --> XFRMGRP_ACQURE
>  acquire as it would right now with an outbound packet

You're right.  Neither xfrm_user/af_key is doing this at the moment.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
