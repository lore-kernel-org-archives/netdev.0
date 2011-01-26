From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 13:33:28 -0800
Message-ID: <1296077608.2448.13.camel@Joe-Laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
	 <1296073390.2631.4.camel@edumazet-laptop>
	 <1296077098.2448.5.camel@Joe-Laptop>
	 <1296077287.2631.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3386 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753565Ab1AZVd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 16:33:29 -0500
In-Reply-To: <1296077287.2631.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-26 at 22:28 +0100, Eric Dumazet wrote:
> Le mercredi 26 janvier 2011 =C3=A0 13:24 -0800, Joe Perches a =C3=A9c=
rit :
> > Ugly maybe, but correct, definitely.
> > The same can not be said of the {0}.
> What about fixing real problems Joe ?

What about it?  You seem to have fixed it.

> Are you telling me I dont know C ?

All I'm saying is that from a style and auditing
perspective, it's better to use memset for all
structs that are exposed to user space.

Other than that, there's no issue here.

cheers, Joe


