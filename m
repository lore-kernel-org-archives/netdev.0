From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 11:16:32 +1000
Message-ID: <20050518011632.GA27813@gondor.apana.org.au>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050518004733.GG13748@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2005 at 02:47:33AM +0200, Thomas Graf wrote:
> 
> I like this, although the problem is derived to the definition
> of the threshold. Any ideas on how to define this? A

The threshold doesn't need to be very large at all since it is
essentially the maximum reordering distance that we allow.

However, for an initial estimate we can be conservative and
use something like 30000.  If we're too conservative the SGI
guys will tell us :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
