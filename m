From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Add barriers for dst refcnt
Date: Sun, 6 Feb 2005 18:04:03 +1100
Message-ID: <20050206070403.GA5996@gondor.apana.org.au>
References: <20050204073311.GA11716@gondor.apana.org.au> <20050205172101.7874e1dd.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, anton@samba.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050205172101.7874e1dd.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 05, 2005 at 05:21:01PM -0800, David S. Miller wrote:
> 
> I "think" the dst_release() case is theoretical.  dst_release()
> runs in a locked context for the thing referencing 'dst'.  Be it
> the route hash, a socket, whatever.

Unless dst_run_gc takes the same lock as the context doing the
dst_release you'll still be in trouble :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
