From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Thu, 23 Sep 2004 08:05:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CAFF1-00076S-00@gondolin.me.apana.org.au>
References: <1095888533.4151ee95ed23c@www.katalix.com>
Cc: herbert@gondor.apana.org.au, bcrl@kvack.org, davem@davemloft.net,
        netdev@oss.sgi.com, kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: jchapman@katalix.com (James Chapman)
In-Reply-To: <1095888533.4151ee95ed23c@www.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Chapman <jchapman@katalix.com> wrote:
> 
> We keep coming back to the scalability issue. Sure this driver
> wouldn't work when handling thousands of sessions, but I just don't
> think it's an issue in the VPN case. People will be nailing up their

That's where I disagree.  We don't want to end up with two L2TP
implementations in the kernel, one geared towards large installations
and one geared towards IPsec setups.

So I think both Ben and James need to work out how they can best
absorb the advantages of each other's stack.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
