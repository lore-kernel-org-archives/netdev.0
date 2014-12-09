From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.12+
Date: Tue, 09 Dec 2014 09:54:02 +0100
Message-ID: <3594382.qsqLZcX7yO@storm>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <1417785985.4322.1.camel@edumazet-glaptop2.roam.corp.google.com> <5642727.qTG53DqrAk@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:50752 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbaLIIyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 03:54:06 -0500
In-Reply-To: <5642727.qTG53DqrAk@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 8. December 2014 23:20:42 Wolfgang Walter wrote:
> Am Freitag, 5. Dezember 2014, 05:26:25 schrieb Eric Dumazet:
> > On Fri, 2014-12-05 at 13:09 +0100, Wolfgang Walter wrote:
> > > Hello,
> > > 
> > > as reverting this patch fixes this rather annoying problem: is it
> > > dangerous to revert it as a workaround until the root cause is found?
> > 
> > Unfortunately no, this patch fixes a serious issue.
> > 
> > We need to find the root cause of your problem instead of trying to work
> > around it.
> 
> I only wanted to use it as local workaround here.
> 
> 
> I looked a bit at at code. I'm not familiar with the network code, though
> :-).

If it helps, I'm running the reverted patch on five production boxes hitherto 
without a hiccup. As far as I understood the original commit message,
some packet counters might me wrong without it.

@Eric: What could possibly go wrong(tm)? :)

Of course a real fix is preferred over this band-aid.

Cheers,
Thomas
