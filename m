From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 07:40:00 +1100
Message-ID: <20050304204000.GA14725@gondor.apana.org.au>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050304131419.GE31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 04, 2005 at 02:14:19PM +0100, Thomas Graf wrote:
> 
> I do not agree but I might have a better idea. Let's change iproute2
> to provide a prefixlength of 0 if no prefix was specified and only
> compare the prefixes if it is non zero. This allows for accurate
> deletion, no scripts will break (except for really really broken ones).
> Given there are multiple matching addresses only varying in prefix
> length and no prefix was specified the first one will get deleted but
> this is well defined.

Yep this is a good solution.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
