From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Sun, 10 Apr 2005 05:36:35 +1000
Message-ID: <20050409193635.GC9423@gondor.apana.org.au>
References: <20050406212906.GA24775@gondor.apana.org.au> <1112823442.16753.68.camel@beastie> <20050406220417.GA4443@gondor.apana.org.au> <1112826385.16753.99.camel@beastie> <20050407213231.GA28738@gondor.apana.org.au> <1112917001.3893.77.camel@beastie> <20050408113654.GA26095@gondor.apana.org.au> <1112974214.17165.8.camel@mylaptop> <20050409014447.GA22607@gondor.apana.org.au> <1113062579.3893.110.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1113062579.3893.110.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 09, 2005 at 09:02:59AM -0700, Dmitry Yusupov wrote:
> 
> "emergency pool" is a big and generic feature, needs design and
> resolution. it could definitely wait. Do you have something against
> one liner patch for using sk->sk_allocation instead of hard-coded vm
> priority?

Whatever we come up with will need to be maintained as part of
the kernel ABI.  So I'd rather not see a temporary hack carried
around forever.

You can always patch your kernels to do whatever you want of course.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
