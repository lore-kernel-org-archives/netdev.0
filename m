From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Unitialized queue_lock oops?
Date: Sat, 04 Jun 2005 09:51:30 +1000
Message-ID: <E1DeLwo-0005GI-00@gondolin.me.apana.org.au>
References: <20050603232413.GA29308@linuxace.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kernel@linuxace.com (Phil Oester)
In-Reply-To: <20050603232413.GA29308@linuxace.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Phil Oester <kernel@linuxace.com> wrote:
> 
> I know the proposed LLTX changes were meant to address a race while
> the queue_lock was dropped - is the above another illustration of the
> race potential?

I'd say that either you're using a dodgy qdisc, or your hardware is
just stuffed.  That is, if you are using the default qdisc, you should
start looking at replacing pieces of the hardware to find the problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
