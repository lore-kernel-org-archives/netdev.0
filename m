From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Mon, 13 Jun 2005 17:45:21 +1000
Message-ID: <20050613074521.GA21661@gondor.apana.org.au>
References: <20050612123253.GK28759@alpha.home.local> <20050612131323.GA10188@gondor.apana.org.au> <20050612133349.GA6279@gondor.apana.org.au> <20050612134725.GB8951@alpha.home.local> <20050612135018.GA10910@gondor.apana.org.au> <20050612142401.GA10772@alpha.home.local> <20050613044810.GA32103@gondor.apana.org.au> <20050613052148.GF8907@alpha.home.local> <20050613052404.GA7611@gondor.apana.org.au> <20050613061748.GA13144@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
Content-Disposition: inline
In-Reply-To: <20050613061748.GA13144@alpha.home.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2005 at 08:17:48AM +0200, Willy Tarreau wrote:
> 
> What's the problem with the sysctl ? If you prefer, I can change the patch
> to keep the feature enabled by default so that only people aware of the
> problem have to fix it by hand. But I found it better the other way : people
> who need the feature enable it by hand.

Well that's exactly my problem :)

I reckon it should be off by default because the threat posed by
this problem is IMHO small compared to some of the other standard
threats that are applicable to TCP.  Plus this is a well-documented
feature so we can't be sure that someone somewhere isn't depending
on it.

However, if it were off by default then there is very little value
in providing it at all since the same thing can be achived easily
through netfilter.

Anyway, let's leave it to Dave to make the decision.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
