From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Thu, 05 May 2005 18:17:15 -0400
Message-ID: <1115331436.8006.112.camel@localhost.localdomain>
References: <1115298877.7680.75.camel@localhost.localdomain>
	 <20050505213239.GA29526@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050505213239.GA29526@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 07:32 +1000, Herbert Xu wrote:
			
> > +	if (delp && excl) { 
> > +		ret = -EEXIST;
> > +		goto pol_err;
> > +	}
> > +
> > +	/* insert, sorted by prio*/
> >  	write_lock_bh(&xfrm_policy_lock);
> 
> This is still racy since delp can be killed by timers before you get
> the lock.

Ok, Herbert - this is fixable: I take it moving the lock one up is
sufficient; i dont mind if you fix it and add it to your list.

BTW, are the event patches in Davems queue somewhere?
I have a few ipsec ones (cosmetic) that i will send later.

cheers,
jamal
