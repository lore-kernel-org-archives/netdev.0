From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 22:12:19 +1100
Message-ID: <20050220111219.GA25499@gondor.apana.org.au>
References: <4217266F.6090700@trash.net> <20050219184351.GB10773@gondor.apana.org.au> <42182082.9060301@trash.net> <20050220.155527.54695259.yoshfuji@linux-ipv6.org> <20050220073719.GA13008@gondor.apana.org.au> <42184BC2.1030907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        davem@davemloft.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42184BC2.1030907@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 20, 2005 at 09:35:14AM +0100, Patrick McHardy wrote:
> 
> On second thought .. isn't there a risk of confusing userspace by
> changing the masks ?

It only affects xfrm_user users, of which I only know two -- Openswan
and ip(8).  Neither of which should care about it.

However, I forgot to do the fixup in __xfrm[46]_init_tempsel and
that is going to confuse the kernel itself :)

It is looking more and more like a nasty hack though so maybe
it's not worth it since the policy checks are still bloated enough
even after we do this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
