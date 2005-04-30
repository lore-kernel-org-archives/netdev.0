From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Fri, 29 Apr 2005 20:01:21 -0400
Message-ID: <1114819281.8929.9.camel@localhost.localdomain>
References: <20050428022549.GA23556@gondor.apana.org.au>
	 <1114655980.7663.76.camel@localhost.localdomain>
	 <20050428024253.GA23695@gondor.apana.org.au>
	 <1114656932.7663.88.camel@localhost.localdomain>
	 <20050428030325.GB23823@gondor.apana.org.au>
	 <1114658657.7663.110.camel@localhost.localdomain>
	 <1114698033.7663.197.camel@localhost.localdomain>
	 <20050428231154.GA14215@gondor.apana.org.au>
	 <1114779104.7800.22.camel@localhost.localdomain>
	 <1114816846.8929.6.camel@localhost.localdomain>
	 <20050429234952.GB22699@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050429234952.GB22699@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 09:49 +1000, Herbert Xu wrote:
> On Fri, Apr 29, 2005 at 07:20:46PM -0400, jamal wrote:

> 
> >  	write_unlock_bh(&xfrm_policy_lock);
> >  
> > -	if (delpol) {
> > -		xfrm_policy_kill(delpol);
> > +	if (delp) {
> > +		xfrm_policy_kill(delp);
> >  	}
> 
> This is racy.  The policy could be killed by the timer in the middle.
> 

the policy_kill is?

> This is also getting pretty hairy for something that nobody has needed so
> far.  Which user-space application is going to use this index thing?

did you see the attachment i put with ip x tests?

cheers,
jamal
