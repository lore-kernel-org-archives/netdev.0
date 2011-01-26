From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 09:56:18 -0800
Message-ID: <1296064578.6115.39.camel@Joe-Laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <1296064190.2899.88.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3376 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753693Ab1AZR4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 12:56:19 -0500
In-Reply-To: <1296064190.2899.88.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-26 at 18:49 +0100, Eric Dumazet wrote:
> Le mercredi 26 janvier 2011 =C3=A0 09:43 -0800, Joe Perches a =C3=A9c=
rit :
> > I think the best style to use memset so that any
> > possible struct padding is guaranteed to be zeroed.
> We use the { 0 } style in net/sched,

That's nice, but it's the wrong style.
https://lkml.org/lkml/2010/12/15/63

> and there is no padding in this
> structure, I checked this point.

That may be true right now for this particular
structure, but that style is not future-proof.


