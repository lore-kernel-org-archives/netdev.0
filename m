From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 18:13:27 +1000
Message-ID: <20050612081327.GA24384__46930.6077844978$1118564240$gmane$org@gondor.apana.org.au>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
Content-Disposition: inline
In-Reply-To: <20050611195144.GF28759@alpha.home.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 11, 2005 at 09:51:44PM +0200, Willy Tarreau wrote:
> 
> Please note that if I only called it "small DoS", it's clearly because
> I don't consider this critical, but I think that most people involved
> in security will find that DoSes based on port guessing should be
> addressed when possible.

Sorry but this patch is pointless.  If I wanted to prevent you from
connecting to www.kernel.org 80 and I knew your source port number
I'd be directly sending you fake SYN-ACK packets which will kill
your connection immediately.

If you want reliability and security you really should be using IPsec.
There is no other way.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
