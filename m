From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 12:52:18 +1000
Message-ID: <20050404025218.GA17571@gondor.apana.org.au>
References: <1112358278.1096.160.camel@jzny.localdomain> <20050401123554.GA3468@gondor.apana.org.au> <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain> <20050404005805.GA16543@gondor.apana.org.au> <1112582044.1087.421.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112582044.1087.421.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 10:34:04PM -0400, jamal wrote:
> 
> I think you meant pfkey_proto2satype(). i.e 
> hdr->sadb_msg_satype = pfkey_proto2satype(c->data);

Yes I was being dyslexic :)

> BTW, slightly different from the way netlink does bussiness.

You mean how netlink just passes the proto through verbatim?
Yes netlink uses the natural representation wherever possible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
