From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 26 Mar 2005 15:05:05 -0500
Message-ID: <1111867505.1089.907.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194006.GA9737@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326194006.GA9737@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-26 at 14:40, Herbert Xu wrote:
> On Sat, Mar 26, 2005 at 02:22:51PM -0500, jamal wrote:
> >
> > --- a/include/linux/xfrm.h	2005/03/26 18:30:26	1.1
> > +++ b/include/linux/xfrm.h	2005/03/26 18:47:48
> > @@ -254,5 +254,8 @@
> >  
> >  #define XFRMGRP_ACQUIRE		1
> >  #define XFRMGRP_EXPIRE		2
> > +#define XFRMGRP_POLEXPIRE	4
> 
> Is the intention that you'll be sending policy expire messages to
> POLEXPIRE only?

Right. Unless you think this will break existing apps?


> If so please add a new group for SA expire messages only so that
> XFRMGRP_EXPIRE continues to get all expire messages for compatibility.
> 

Ok, i should have read ahead ;->
Maybe i should leave EXPIRE alone?

cheers,
jamal
