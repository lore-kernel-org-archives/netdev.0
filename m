From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Wed, 6 Apr 2005 12:21:55 +1000
Message-ID: <20050406022155.GA12952@gondor.apana.org.au>
References: <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au> <20050331212325.5e996432.davem@davemloft.net> <20050402004956.GA24339@gondor.apana.org.au> <20050401172007.7296eced.davem@davemloft.net> <20050402020947.GA24998@gondor.apana.org.au> <42501E51.3000401@trash.net> <20050405103918.GA24863@gondor.apana.org.au> <4252EEA2.5020107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4252EEA2.5020107@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2005 at 10:01:38PM +0200, Patrick McHardy wrote:
> 
> Good idea, I didn't think of this. This patch is without replacement of
> xfrm_init_tempsel(), it caused an "unused function" warning and, as I
> mentioned before, I still need the function.

Thanks.  Just one more issue that I can think of, the check should
only be done when tmpl->id.spi != 0.  Otherwise the presence of
valid states with differing state selectors will prevent new
sessions from starting up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
