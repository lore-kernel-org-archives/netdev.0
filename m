From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Add nl_open to libnetlink
Date: Wed, 7 Jul 2004 21:03:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707110315.GA26100@gondor.apana.org.au>
References: <20040703094632.GA14235@gondor.apana.org.au> <20040705160500.208591b5@localhost> <20040706140550.2d483dc8@dell_ss3.pdx.osdl.net> <20040707130950.0112edf6@localhost> <20040707140533.41c66c03@localhost> <20040707155602.4698121a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040707155602.4698121a@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 03:56:02PM +0900, Masahide NAKAMURA wrote:
> 
> I've updated the patch and it can build with 2.6.7 kernel headers.
> Can you check it?
> 
> http://www.linux-ipv6.org/~nakam/ipxfrm-20040707_2.diff

Thanks.

Could you please change the output of ip xfrm policy/state so that
it can be fed directly back in? For example the output of ip ro ls
can be fed back into ip ro add.

Could you please also make it understand ip x p instead of ip x policy?

And there seems to be something wrong with the keys in the output of
ip x state.  There are too many f's for it to be right.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
