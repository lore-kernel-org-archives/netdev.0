From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sun, 27 Mar 2005 05:42:17 +1000
Message-ID: <20050326194217.GA9778@gondor.apana.org.au>
References: <E1DF15m-0006JT-00@gondolin.me.apana.org.au> <1111862486.1090.880.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, nakam@linux-ipv6.org,
        shinta.sugimoto@ericsson.com, netdev <netdev@oss.sgi.com>,
        Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111862486.1090.880.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 01:41:27PM -0500, jamal wrote:
> 
> I noticed in the absence of a responsive KM, the acquires are sent
> forever. Is it 30 seconds and may be degenerating to 60 seconds?
> In the meantime my ping is sitting there not giving me back the prompt.
> I suspect this is so as to make it reliable and maybe aggrevated by the
> fact i can now passively monitor with ip xfrm mon.

It's only sitting there forever because ping is configured to send
packets forever by default.

Try ping -c 1 and things will probably be different.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
