From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 10:32:12 +1100
Message-ID: <20050304233212.GA27421@gondor.apana.org.au>
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

A bigger problem with this approach is that we don't have a magical
way of getting people to upgrade their ip(8) binary.

To do this safely, we'll need a way of indicating that the ip(8) binary
is setting the prefixlen in the way you propose.  Perhaps this can be
done using a new IFA payload type.

Alternatively you can use the value of /32 to indicate a wildcard match
instead of /0.  After all, /0 has a specific meaning in this context so
it's just as arbitrary to choose /0 as opposed to /32.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
