From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RTNETLINK] Convert RTM_* to enum
Date: Wed, 15 Sep 2004 13:47:48 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915034748.GA952@gondor.apana.org.au>
References: <20040915020942.GA32721@gondor.apana.org.au> <Xine.LNX.4.44.0409142337130.28280-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0409142337130.28280-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2004 at 11:38:21PM -0400, James Morris wrote:
> 
> Having the enums as well as the defines is messy, I wonder if it's really
> worth it.

I think the enum is definitely worth it for reducing the churn on
the MAX value.

I personally don't see a point to the defines since the user-space
appliations should not change behaviour based on compile-time
settings.  However, others seem to have a different opinion on that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
