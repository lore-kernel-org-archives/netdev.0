From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: net_device flags is an unsigned int
Date: Thu, 01 Dec 2011 00:05:28 -0500 (EST)
Message-ID: <20111201.000528.1901790543147589391.davem@davemloft.net>
References: <1322714077.2577.12.camel@edumazet-laptop>
	<20111130.233918.564313369312715101.davem@davemloft.net>
	<1322714894.2577.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1LAFFa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 00:05:30 -0500
In-Reply-To: <1322714894.2577.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2011 05:48:14 +0100

> Le mercredi 30 novembre 2011 =E0 23:39 -0500, David Miller a =E9crit =
:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 01 Dec 2011 05:34:37 +0100
>>=20
>> > -	unsigned short old_flags =3D dev->flags;
>> > +	typeof(dev->flags) old_flags =3D dev->flags;
>>=20
>> Please, create netdev_flags_t or similar, anything but this :-)
>=20
> Hmm, I thought Linus hated types like this...

Yes, it is true.  But look at netdev_features_t

> Or how explain we dont have jiffies_t or similar ? ;)

:-)

Like you I just want something that automatically tracks any future
changes to the type.  However I want something that doesn't look so
ugly like that typeof() thing.

Sure, use typeof() in macros, you can hide it in such places.

But please not in plain sight in *.c files.
