From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2-2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 23:02:24 +1000
Message-ID: <20050404130224.GA12546@gondor.apana.org.au>
References: <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain> <20050404005805.GA16543@gondor.apana.org.au> <1112614706.1096.439.camel@jzny.localdomain> <20050404121641.GA12103@gondor.apana.org.au> <1112619096.1088.473.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112619096.1088.473.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 08:51:37AM -0400, jamal wrote:
>
> > > -static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> > > -static DEFINE_RWLOCK(xfrm_km_lock);
> > 
> > How about letting these guys stay where they are? The move was
> > necessary before because the km_*_notify functions had to be called
> > in this file but that's no longer the case.
> 
> Changed 
> - dont see what the harm was as they were in that patch though.

Please see below.

> +static DEFINE_RWLOCK(xfrm_km_lock);
> +static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
>  EXPORT_SYMBOL(xfrm_replay_advance);
>  
> -static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> -static DEFINE_RWLOCK(xfrm_km_lock);

All I wanted was to leave these lines as is so that they didn't
appear in the patch at all (except as conext) :)

When reviewing patches the most annoying thing is to see things
moved around or rearranged because that distracts the reviewer
from the substantiative changes.
 
> ;-> Yes, indeed. I think its time for you to throw in the towel ;->

Alright I give in :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
