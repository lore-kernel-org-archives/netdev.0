From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Wed, 10 Nov 2004 08:06:11 +1100
Message-ID: <E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
References: <20041109205358.GA64015@calma.pair.com>
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: chad@tindel.net (Chad N. Tindel)
In-Reply-To: <20041109205358.GA64015@calma.pair.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chad N. Tindel <chad@tindel.net> wrote:
> 
> In our testing we've found some occurrences of identd reporting back the
> wrong username for the owner of a socket.  We added some instrumentation

/proc/net/tcp is an obsolete interface.  It is inherently unreliable
in that a record may be read using two read(2) calls.  Those two calls
may end up looking at two different records.

So please use the netlink interface or ss(8) from the iproute package.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
