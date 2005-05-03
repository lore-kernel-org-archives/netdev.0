From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Tue, 3 May 2005 21:23:10 +1000
Message-ID: <20050503112310.GA30356@gondor.apana.org.au>
References: <4276B13F.2040103@tpack.net> <20050503100306.GB29788@gondor.apana.org.au> <20050503111844.GP577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tommy Christensen <tommy.christensen@tpack.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050503111844.GP577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2005 at 01:18:44PM +0200, Thomas Graf wrote:
> 
> I do like the patch, no question but IFF_RUNNING is still abused
> by drivers and some subsystems. So I'm not sure how reliable the
> above code will be without those cases fixed. I submitted a

Ouch, you're right.  They either need to be fixed or we'll just
have to go back to the simpler version that may call
dev_activate/dev_deactivate repeatedly.

> patchset once to fix some of them, not sure about the status. Also,
> what about those drivers that do not support or do not use
> netif_carrier_(on|off)?

They simply won't benefit from this patch.  This is OK since they're
no worse off than where they were before.  It might also prove to be
an incentive for someone to finally fix them :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
