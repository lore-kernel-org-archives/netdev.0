From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Sun, 2 Oct 2005 05:29:34 +1000
Message-ID: <20051001192934.GA20741__42825.3043363386$1128195196$gmane$org@gondor.apana.org.au>
References: <200510011837.j91IbE01012915@rastaban.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert.Olsson@data.slu.se, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Suzanne Wood <suzannew@cs.pdx.edu>
Content-Disposition: inline
In-Reply-To: <200510011837.j91IbE01012915@rastaban.cs.pdx.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 01, 2005 at 11:37:14AM -0700, Suzanne Wood wrote:
> 
> But the following may be worth considering.
> 
>   > It is also probably good to retain the old __in_dev_get()
> and deprecate it.

I think it's better to get rid of it actually so that if there are
external modules using this they can make sure that they're using
the right function.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
