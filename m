From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NETLINK_ROUTE sockets in kernel
Date: Wed, 03 Nov 2004 09:15:12 +1100
Message-ID: <E1CP6vo-0003Uf-00@gondolin.me.apana.org.au>
References: <2f61ba570411021146657f63f4@mail.gmail.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anil Gunturu <anil.gunturu@gmail.com>
In-Reply-To: <2f61ba570411021146657f63f4@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anil Gunturu <anil.gunturu@gmail.com> wrote:
>
> kernel. But its not clear on how the rtnetlink_links array is
> populated for PF_NETLINK family. rtnetlink_init seem to populate for

rtnetlink_links[PF_NETLINK] doesn't make sense.  We don't have a
routing system for NETLINK itself, yet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
