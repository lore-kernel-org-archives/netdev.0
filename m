From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 17:05:02 +1000
Message-ID: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au>
References: <445835BB.4050000@corky.net>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:19466 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965117AbWECHFF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 03:05:05 -0400
To: marc@corky.net (Just Marc)
In-Reply-To: <445835BB.4050000@corky.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just Marc <marc@corky.net> wrote:
> 
> We're now at 2.6.16.12 and it is still showing thousands of times a day 
> on a busy web server, have all the bugs been discovered yet?

There are no known bugs on the RX side in 2.6.16 that would cause this.
The few busy web servers that I have access to do not see this message
at all.

So either your web server is somehow attracting a lot of buggy TCP stacks,
or there could be a dodgy gateway in your path that is mucking with the
TCP windows.

I suggest that you do a tcpdump to see what it looks like.  It might turn
out that we do still have a bug on our RX side.

BTW, this message is already under net_ratelimit so I don't see any
urgency in getting rid of it completely.  If we're going down the
path of disabling it, we probably should go for something more global
rather than a sysctl that controls this one message.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
