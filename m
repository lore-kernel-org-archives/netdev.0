From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 22 Sep 2004 13:39:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922033931.GA14747@gondor.apana.org.au>
References: <414DF11C.1080505@eurodev.net> <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <1095821845.1047.9.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095821845.1047.9.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 10:57:26PM -0400, jamal wrote:
> 
> > Secondly each of your user-space messages is producing a number of
> > replies.  This should be done as a dump operation.  If you do it as
> > a dump operation, then you will never get overruns because the kernel
> > never sends more than the user can handle.
> 
> This is not accurate. You will get overruns. Try adding a few thousand
> ipsec policies and then dumping them. Perhaps we can have the cb reset
> in case of overrun detection.

I just happen to have a few thousand ipsec policies :) I dump them
all the time with the great new tool in iproute and I've never had
any overruns.  In contrast whenever I use setkey to dump them over
PFKEY it dies very quickly indeed.

I bet that there is a bug somewhere in the tc stuff.  Let me have a look.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
