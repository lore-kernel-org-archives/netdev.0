From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 22:31:15 -0800 (PST)
Message-ID: <20101129.223115.260071567.davem@davemloft.net>
References: <1291095736.2725.5.camel@edumazet-laptop>
	<20101129.215303.48488457.davem@davemloft.net>
	<1291097479.2725.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751957Ab0K3Gat convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 01:30:49 -0500
In-Reply-To: <1291097479.2725.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Nov 2010 07:11:19 +0100

> Le lundi 29 novembre 2010 =E0 21:53 -0800, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 30 Nov 2010 06:42:16 +0100
>>=20
>> > Its a bit early in the morning here, I must confess I dont yet
>> > understand your patch David :)
>> >=20
>> > As we use a tree, why not using two different trees for ipv4 / ipv=
6 ?
>>=20
>> The "key" just creates a natural ordering in the tree, it's
>> almost arbitrary except that it must distribute well amongst
>> the entries.
>=20
> Hmm. AVL search must take a decision, take the left or the right path=
=2E
>=20
> if current key is equal, which path do you take ?

Right. :-)  But yes there is some error that needs to
be handled in that equal keys can lead to imporper paths
as you showed.

I guess I do need to make a seperate tree, how disappointing.

Anyways I will work on fixing this.

> Do you know how to make an estimation on a server ?

No way to do it straightforward I guess because right now TCP metrics
key on all sorts of rediculious things like source address, TOS, and
other crap as a consequence of how the routing cache works.

So much replicated information and wasted memory.

