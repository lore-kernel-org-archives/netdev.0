From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sun, 27 Mar 2005 05:45:03 +1000
Message-ID: <20050326194503.GA9826@gondor.apana.org.au>
References: <E1DF15m-0006JT-00@gondolin.me.apana.org.au> <1111862486.1090.880.camel@jzny.localdomain> <20050326194217.GA9778@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, nakam@linux-ipv6.org,
        shinta.sugimoto@ericsson.com, netdev <netdev@oss.sgi.com>,
        Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050326194217.GA9778@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 27, 2005 at 05:42:17AM +1000, herbert wrote:
> 
> It's only sitting there forever because ping is configured to send
> packets forever by default.
> 
> Try ping -c 1 and things will probably be different.

Actually it won't.  It will try it forever when the larval state
expires.  When we fix the xfrm state resolution, we can add a
knob for this case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
