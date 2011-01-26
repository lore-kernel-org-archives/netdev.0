From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 11:56:04 -0800 (PST)
Message-ID: <20110126.115604.71133457.davem@davemloft.net>
References: <1296063823.6115.37.camel@Joe-Laptop>
	<1296064190.2899.88.camel@edumazet-laptop>
	<1296064578.6115.39.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753248Ab1AZTz3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 14:55:29 -0500
In-Reply-To: <1296064578.6115.39.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Wed, 26 Jan 2011 09:56:18 -0800

> On Wed, 2011-01-26 at 18:49 +0100, Eric Dumazet wrote:
>> Le mercredi 26 janvier 2011 =E0 09:43 -0800, Joe Perches a =E9crit :
>> > I think the best style to use memset so that any
>> > possible struct padding is guaranteed to be zeroed.
>> We use the { 0 } style in net/sched,
>=20
> That's nice, but it's the wrong style.
> https://lkml.org/lkml/2010/12/15/63
>=20
>> and there is no padding in this
>> structure, I checked this point.
>=20
> That may be true right now for this particular
> structure, but that style is not future-proof.

It is future-proof if the data-structure is user-visible and therefore
will never change, as is the case here.
