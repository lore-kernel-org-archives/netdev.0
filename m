From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 15:23:14 -0500 (EST)
Message-ID: <20120223.152314.1111200746248162115.davem@davemloft.net>
References: <1330007786.15610.26.camel@edumazet-laptop>
	<20120223.151115.1646872434333284038.davem@davemloft.net>
	<1330028243.15610.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756528Ab2BWUX7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 15:23:59 -0500
In-Reply-To: <1330028243.15610.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Feb 2012 21:17:23 +0100

> Le jeudi 23 f=E9vrier 2012 =E0 15:11 -0500, David Miller a =E9crit :
>> Three instances of the same piece of code, maybe a helper function i=
s
>> appropriate at that point? :-) You might even get ambitious and add =
a
>> big comment to that helper function explaining the situation.
>=20
> I did have this idea but refrained because this kind of things is har=
der
> to backport to stable kernels.
>=20
> I'll make a cleanup in net-next if you agree ?

I think the work to backport is equal whether you use a helper function
or not.  Heck, use an inline function so you don't have to worry about
module exports or any details like that.

Besides, I'm the one who likely has to backport this thing, so... :-)
