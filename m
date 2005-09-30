From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Fri, 30 Sep 2005 11:19:07 +1000
Message-ID: <20050930011907.GA21579__47364.7373648875$1128043318$gmane$org@gondor.apana.org.au>
References: <200509292330.j8TNUSmH019572@rastaban.cs.pdx.edu> <20050930002346.GP8177@us.ibm.com> <20050930002719.GC21062@gondor.apana.org.au> <20050930003642.GQ8177@us.ibm.com> <20050930010404.GA21429@gondor.apana.org.au> <20050930011603.GT8177@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suzanne Wood <suzannew@cs.pdx.edu>, Robert.Olsson@data.slu.se,
        davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050930011603.GT8177@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2005 at 06:16:03PM -0700, Paul E. McKenney wrote:
> 
> OK, how about this instead?
> 
> 	rcu_read_lock();
> 	in_dev = dev->ip_ptr;
> 	if (in_dev) {
> 		atomic_inc(&rcu_dereference(in_dev)->refcnt);
> 	}
> 	rcu_read_unlock();
> 	return in_dev;

Looks great.  Thanks Paul.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
