From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Modularise tcpdiag
Date: Sat, 30 Oct 2004 09:13:14 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029231314.GA17928@gondor.apana.org.au>
References: <20041029043858.GA27907@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041029043858.GA27907@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 02:38:58PM +1000, herbert wrote:
> 
> Next we can move out the IPv6-specific stuff.

Actually, perhaps it's time to turn tcpdiag into sockdiag and do
all families & protocols.  It's a bit ironic that we have to poke
into procfs to see netlink sockets :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
