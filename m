From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RTNETLINK] Provide real oif
Date: Thu, 4 Dec 2003 06:51:34 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031203195134.GD4482@gondor.apana.org.au>
References: <E1ARULX-0000Ny-00@gondolin.me.apana.org.au> <1070459463.1036.179.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1070459463.1036.179.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 03, 2003 at 08:51:03AM -0500, jamal wrote:
> 
> I am wondering if they should have been the same resolved 
> cache entry to begin with. i.e the fl->oif should not have 
> been 0 rather the ifindex of eth0.
> Even in the case of multipath routing, you have to wait for 
> the cache to expire before selecting the next one in the slow 
> path; so fl->oif of zero may not be a very useful artifact. 

That would be good.  In fact, I think that's how IPv6 works.

Dave, is this acceptable?
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
