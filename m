From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [15/*] [INET] Fix IPsec calculation in ip_append_data/ip6_append_data
Date: Tue, 22 Mar 2005 09:04:40 +1100
Message-ID: <20050321220440.GA5868@gondor.apana.org.au>
References: <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050316113149.GA10960@gondor.apana.org.au> <423EF2CF.7020403@kolumbus.fi> <20050321202804.GA3106@gondor.apana.org.au> <423F3CD6.7090109@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: Mika Penttil? <mika.penttila@kolumbus.fi>
Content-Disposition: inline
In-Reply-To: <423F3CD6.7090109@kolumbus.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2005 at 11:29:58PM +0200, Mika Penttil? wrote:
>
> ok I see it now, but this is really easy to get wrong...

Well the rule is actually quite simple.  If IPsec can't be present,
then you should always use dst_mtu(dst).  If IPsec may be present,
then you should also use dst_mtu(dst) *unless* you're performing an
operation such as fragmentation that has to be done after IPsec.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
