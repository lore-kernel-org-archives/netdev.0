From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: shorten timer period for slave devices
Date: Tue, 14 Feb 2012 16:28:05 -0500 (EST)
Message-ID: <20120214.162805.235395266188685036.davem@davemloft.net>
References: <1329251229.2555.10.camel@edumazet-laptop>
	<1329252670.3054.85.camel@dcbw.foobar.com>
	<1329253376.2555.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, klassert@mathematik.tu-chemnitz.de,
	jdelvare@suse.de, fubar@us.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2BNV2e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:28:34 -0500
In-Reply-To: <1329253376.2555.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Feb 2012 22:02:56 +0100

> Le mardi 14 f=E9vrier 2012 =E0 14:51 -0600, Dan Williams a =E9crit :
>> On Tue, 2012-02-14 at 21:27 +0100, Eric Dumazet wrote:
>> > Jean Delvare reported bonding on top of 3c59x adapters was not det=
ecting
>> > network cable removal fast enough.
>> >=20
>> > 3c59x indeed uses a 60 seconds timer to check link status if carri=
er is
>> > on, and 5 seconds if carrier is off.
>> >=20
>> > This patch reduces timer period to 5 seconds if device is a bondin=
g
>> > slave.
>>=20
>> Maybe for posterity give some rationale as to why we feel we can red=
uce
>> it to 5 seconds for slaves instead of reducing the timer period in
>> general?  If you weren't party to this discussion that won't be appa=
rent
>> from the commit log.
>=20
> Apparently, Andrew Morton considered firing a timer every 5 seconds w=
as
> too expensive. I am not sure we want to state this (probably old fact=
)
> in the changelog. Anyway are these slow NICS still used in 2011 ? ;)

At least Jean Delvare is :-)

I'm going to apply this as-is, if you configure bonding on one of these
chips you expect it to work.  And working is more important than optima=
l.
