From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Wed, 18 Jan 2012 12:01:45 -0500 (EST)
Message-ID: <20120118.120145.1561133318520188723.davem@davemloft.net>
References: <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<9903c7bcb83314b495e7378dae23e703@localhost>
	<1326898746.2316.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tore@fud.no, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214Ab2ARRCz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:02:55 -0500
In-Reply-To: <1326898746.2316.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2012 15:59:06 +0100

> Le mercredi 18 janvier 2012 =E0 15:43 +0100, Tore Anderson a =E9crit =
:
>=20
>> Another way of solving it and avoiding the Fragmentation headers
>> altogether would be to allow the "route MTU" to drop below 1280 as a
>> result of Path MTU Discovery. I opened an enchancement bug report
>> requesting this:
>>=20
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D42599
>=20
> Please dont open bugzilla entries for this kind of stuff, since there=
 is
> no bug in this case.

Plus, we really don't normally follow the bugzilla reports at all, and
as Eric states just report them here to the netdev list if you want
something looked into.
