From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Tue, 09 Dec 2014 15:49:08 +0100
Message-ID: <1944212.qBNvTmfA92@storm>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <3594382.qsqLZcX7yO@storm> <1418135209.14835.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7Bit
Cc: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:36150 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbaLIOtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 09:49:14 -0500
In-Reply-To: <1418135209.14835.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 9. December 2014 06:26:49 Eric Dumazet wrote:
> > If it helps, I'm running the reverted patch on five production boxes
> > hitherto without a hiccup. As far as I understood the original commit
> > message, some packet counters might me wrong without it.
> > 
> > @Eric: What could possibly go wrong(tm)? :)
> 
> Crashes in TCP stack, because of packet count mismatches.

alright, that sounds like a pretty good argument.

> ...
> I would disable TSO/GSO on xfrm, and problem should disappear.

I guess you can't explicitly disable this with the "ip xfrm" command?
Or do you mean this should be disabled on the ethX device
serving the xfrm connection?

We are about to push out this code to ten more machines,
so the best time (for me) to do any changes  that increases
stability would be now :o)

Cheers,
Thomas
