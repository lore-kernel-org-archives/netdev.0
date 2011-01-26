From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 13:24:58 -0800
Message-ID: <1296077098.2448.5.camel@Joe-Laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
	 <1296073390.2631.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3381 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487Ab1AZVZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 16:25:00 -0500
In-Reply-To: <1296073390.2631.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-26 at 21:23 +0100, Eric Dumazet wrote:
> Le mercredi 26 janvier 2011 =C3=A0 11:55 -0800, David Miller a =C3=A9=
crit :
> > From: Joe Perches <joe@perches.com>
> > > I think the best style to use memset so that any
> > > possible struct padding is guaranteed to be zeroed.
> > Such padding does not exist, and we won't add such padding since th=
is is
> > a user visible data structure and thus whose layout is cast in ston=
e.
> > Anyways, I'm ambivalent to how this is fixed actually.
> I am perfectly aware of this ugly memset() style some people prefer, =
and
> 5 % of the time they swap 2nd and 3rd param.

Ugly maybe, but correct, definitely.
The same can not be said of the {0}.

This use ends up the same so it doesn't
matter here, it's just a style question.

> Two patches instead of one ;)

How uninteresting.  Any API can be misused.

> In this particular case, I only used existing codestyle: In the same
> file I noticed :

There are memset's in the file as well.
In fact, memset is used in the same function.

cheers, Joe

